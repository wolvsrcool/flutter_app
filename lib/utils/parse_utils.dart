import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:my_project/models/schedule_model.dart';

class ParseUtils {
  static List<Schedule> parseSchedule(String htmlContent, String group) {
    final document = parser.parse(htmlContent);
    final List<Schedule> schedules = [];

    try {
      final daySections = _extractDaySections(document);

      for (final daySection in daySections.entries) {
        final dayName = daySection.key;
        final dayElement = daySection.value;

        final pairs = _extractPairsForDay(dayElement);

        for (final pair in pairs.entries) {
          final pairNumber = pair.key;
          final pairElement = pair.value;
          final scheduleElements = pairElement.querySelectorAll(
            '[id^="group_"], [id^="sub_"]',
          );

          for (final scheduleElement in scheduleElements) {
            final contentDiv = scheduleElement.querySelector('.group_content');
            if (contentDiv == null) continue;

            final html = contentDiv.innerHtml;

            final weekType = _determineWeekType(scheduleElement);

            final subgroup = _determineSubgroup(scheduleElement);

            final parts = html.split('<br>');
            final cleanParts = parts
                .map((part) => part.replaceAll(RegExp(r'<[^>]*>'), '').trim())
                .where(
                  (part) =>
                      part.isNotEmpty && !part.contains('URL онлайн-заняття'),
                )
                .toList();

            if (cleanParts.length >= 2) {
              final subject = cleanParts[0];
              final details = cleanParts[1];

              final detailsParts = details
                  .split(',')
                  .map((p) => p.trim())
                  .toList();
              final String teacher = detailsParts.isNotEmpty
                  ? detailsParts[0]
                  : 'Не вказано';
              String classroom = 'Не вказано';
              String type = 'Заняття';

              for (final part in detailsParts) {
                if (part.contains('Лекція')) {
                  type = 'Лекція';
                } else if (part.contains('Практична')) {
                  type = 'Практична';
                } else if (part.contains('Лабораторна')) {
                  type = 'Лабораторна';
                }
              }

              if (detailsParts.length > 1) {
                final classroomParts = detailsParts
                    .sublist(1)
                    .where((p) => !_isLessonType(p))
                    .toList();
                if (classroomParts.isNotEmpty) {
                  classroom = classroomParts.join(', ');
                }
              }

              if (html.contains('schedule_url_link')) {
                classroom = 'Онлайн';
              }

              final schedule = Schedule(
                time: _getTimeForPair(pairNumber),
                subject: subject,
                teacher: teacher,
                classroom: classroom,
                type: type,
                day: dayName,
                weekType: weekType,
                subgroup: subgroup,
              );
              schedules.add(schedule);
            }
          }
        }
      }
    } catch (e) {
      return [];
    }
    return schedules;
  }

  static String _determineWeekType(Element scheduleElement) {
    final id = scheduleElement.attributes['id'] ?? '';

    if (id.contains('_chys')) {
      return 'chys';
    } else if (id.contains('_znam')) {
      return 'znam';
    } else if (id.contains('_full')) {
      return 'full';
    }

    final classes = scheduleElement.classes;

    if (classes.contains('group_chys') ||
        classes.contains('sub_1_chys') ||
        classes.contains('sub_2_chys')) {
      return 'chys';
    } else if (classes.contains('group_znam') ||
        classes.contains('sub_1_znam') ||
        classes.contains('sub_2_znam')) {
      return 'znam';
    } else if (classes.contains('group_full') ||
        classes.contains('sub_1_full') ||
        classes.contains('sub_2_full')) {
      return 'full';
    }

    var parent = scheduleElement.parent;
    while (parent != null) {
      final parentClasses = parent.classes;
      final parentId = parent.attributes['id'] ?? '';

      if (parentId.contains('_chys') || parentClasses.contains('group_chys')) {
        return 'chys';
      } else if (parentId.contains('_znam') ||
          parentClasses.contains('group_znam')) {
        return 'znam';
      } else if (parentId.contains('_full') ||
          parentClasses.contains('group_full')) {
        return 'full';
      }

      parent = parent.parent;
    }

    final dayStructure = _analyzeDayStructure(scheduleElement);
    if (dayStructure.isNotEmpty) {
      return dayStructure;
    }

    return 'full';
  }

  static String _analyzeDayStructure(Element element) {
    final parent = element.parent;
    if (parent != null) {
      final siblings = parent.querySelectorAll('[id^="group_"], [id^="sub_"]');
      for (final sibling in siblings) {
        final siblingId = sibling.attributes['id'] ?? '';
        if (siblingId.contains('_znam')) {
          return 'chys';
        } else if (siblingId.contains('_chys')) {
          return 'znam';
        }
      }
    }
    return '';
  }

  static String _determineSubgroup(Element scheduleElement) {
    final id = scheduleElement.attributes['id'] ?? '';

    if (id.contains('sub_1')) {
      return '1';
    } else if (id.contains('sub_2')) {
      return '2';
    } else if (id.contains('group_')) {
      return '0';
    }

    return '0';
  }

  static Map<String, Element> _extractDaySections(Document document) {
    final Map<String, Element> daySections = {};
    final dayHeaders = document.querySelectorAll('.view-grouping-header');

    for (final header in dayHeaders) {
      final dayName = header.text.trim();

      var currentElement = header.nextElementSibling;
      final dayElements = <Element>[];

      while (currentElement != null &&
          !currentElement.classes.contains('view-grouping-header') &&
          currentElement.localName != null) {
        dayElements.add(currentElement);
        currentElement = currentElement.nextElementSibling;
      }

      if (dayElements.isNotEmpty) {
        final dayContainer = document.createElement('div');
        for (final element in dayElements) {
          dayContainer.append(element.clone(true));
        }
        daySections[dayName] = dayContainer;
      }
    }

    return daySections;
  }

  static Map<String, Element> _extractPairsForDay(Element dayContent) {
    final Map<String, Element> pairs = {};
    final pairHeaders = dayContent.querySelectorAll('h3');

    for (final header in pairHeaders) {
      final pairNumber = header.text.trim();
      final scheduleBlock = header.nextElementSibling;
      if (scheduleBlock != null &&
          scheduleBlock.classes.contains('stud_schedule')) {
        pairs[pairNumber] = scheduleBlock;
      }
    }

    return pairs;
  }

  static String _getTimeForPair(String pairNumber) {
    final times = {
      '1': '08:30 - 9:50',
      '2': '10:05 - 11:25',
      '3': '11:40 - 13:00',
      '4': '13:15 - 14:35',
      '5': '14:50 - 16:10',
      '6': '16:25 - 17:45',
      '7': '18:00 - 19:20',
      '8': '19:30 - 20:50',
    };

    return times[pairNumber] ?? '???';
  }

  static bool _isLessonType(String text) {
    return text.contains('Лекція') ||
        text.contains('Практична') ||
        text.contains('Лабораторна');
  }
}
