import 'dart:io';
import 'dart:convert';

// EVENT MANAGEMENT SYSTEM

// STEP 1: CREATING THE EVENT CLASS
class Event {
  // Constructor initialization
  Event({
    required this.title,
    required this.datetime,
    required this.location,
    required this.description,
  });

  String title;
  DateTime datetime;
  String location;
  String description;
  List<Attendee> attendees = [];

  // Convert Event object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'datetime': datetime.toIso8601String(),
      'location': location,
      'description': description,
      'attendees': attendees.map((attendee) => attendee.toJson()).toList(),
    };
  }

  // Create an Event object from a JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      datetime: DateTime.parse(json['datetime']),
      location: json['location'],
      description: json['description'],
    )..attendees = (json['attendees'] as List<dynamic>)
        .map((attendeeJson) => Attendee.fromJson(attendeeJson))
        .toList();
  }

  @override
  String toString() {
    return 'Title: $title,\nDatetime: $datetime,\nLocation: $location,\nDescription: $description';
  }
}

// STEP 2: CREATING THE ATTENDEE CLASS
class Attendee {
  // Constructor initialization
  Attendee({required this.name, this.isPresent = false});

  String name;
  bool isPresent;

  // Convert Attendee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPresent': isPresent,
    };
  }

  // Create an Attendee object from a JSON map
  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      name: json['name'],
      isPresent: json['isPresent'],
    );
  }

  @override
  String toString() {
    return '$name (${isPresent ? 'Present' : 'Absent'})';
  }
}

// STEP 3: CREATING THE EVENT MANAGER CLASS
class EventManager {
  List<Event> events = [];

  // A method to add events
  void addEvent(String title, DateTime datetime, String location, String description) {
    events.add(Event(title: title, datetime: datetime, location: location, description: description));
    print('This event: "$title" has been successfully added to the list.');
  }

  // A method to edit events
  void editEvent(int index, String title, DateTime datetime, String location, String description) {
    if (index >= 0 && index < events.length) {
      events[index]
        ..title = title
        ..datetime = datetime
        ..location = location
        ..description = description;
      print('Event "$title" updated successfully.');
    } else {
      print('Invalid event index.');
    }
  }

  // A method to delete an event
  void deleteEvent(int index) {
    if (index < 0 || index >= events.length) {
      print('No event found at this index');
      return;
    }
    events.removeAt(index);
    print('The event found at index $index has been removed from the list.');
  }

  // A method to list all events
  void listEvents() {
    if (events.isEmpty) {
      print('The events list is empty');
    } else {
      print('List of events:');
      for (var i = 0; i < events.length; i++) {
        print('${i + 1}. ${events[i]}');
      }
    }
  }

  // Method to list events chronologically
  void listEventsChronologically() {
    events.sort((a, b) => a.datetime.compareTo(b.datetime));
    listEvents();
  }

  // Check for schedule conflicts
  void checkScheduleConflict(DateTime datetime) {
    var conflictingEvents = events.where((event) => event.datetime.isAtSameMomentAs(datetime)).toList();
    if (conflictingEvents.isEmpty) {
      print('No events are scheduled at the given datetime.');
    } else {
      print('Conflicting events at the given datetime:');
      for (var event in conflictingEvents) {
        print(event);
      }
    }
  }

  // Register an attendee for an event
  void registerAttendee(int eventIndex, Attendee attendee) {
    if (eventIndex < 0 || eventIndex >= events.length) {
      print('No event found at this index');
      return;
    }
    events[eventIndex].attendees.add(attendee);
    print('Attendee ${attendee.name} registered successfully.');
  }

  // List attendees for an event
  void listAttendees(int eventIndex) {
    if (eventIndex < 0 || eventIndex >= events.length) {
      print('No event found at this index');
      return;
    }

    var event = events[eventIndex];
    if (event.attendees.isEmpty) {
      print('No attendees registered for the event "${event.title}".');
      return;
    }

    for (var attendee in event.attendees) {
      print('Attendee: ${attendee.name} - ${attendee.isPresent ? "Present" : "Absent"}');
    }
  }

  // A method to mark attendance
  void markAttendance(int eventIndex, int attendeeIndex, bool isPresent) {
    if (eventIndex >= 0 && eventIndex < events.length) {
      if (attendeeIndex >= 0 && attendeeIndex < events[eventIndex].attendees.length) {
        events[eventIndex].attendees[attendeeIndex].isPresent = isPresent;
        print('Attendance updated for attendee "${events[eventIndex].attendees[attendeeIndex].name}".');
      } else {
        print('Invalid attendee index.');
      }
    } else {
      print('Invalid event index.');
    }
  }

  // Method to save events to a JSON file
  void saveEventsToFile(String filePath) {
    List<Map<String, dynamic>> jsonEvents =
        events.map((event) => event.toJson()).toList();
    String jsonString = jsonEncode(jsonEvents);
    File file = File(filePath);
    file.writeAsStringSync(jsonString);
    print("Events saved to $filePath");
  }

  // Method to load events from a JSON file
  void loadEventsFromFile(String filePath) {
    try {
      File file = File(filePath);
      String jsonString = file.readAsStringSync();
      List<dynamic> jsonList = jsonDecode(jsonString);
      events.clear();
      for (var jsonEvent in jsonList) {
        events.add(Event.fromJson(jsonEvent));
      }
      print("Events loaded from $filePath");
    } catch (e) {
      print("Error loading events from file: $e");
    }
  }
}

// Main function to handle the event manager application
void main() {
  final eventManager = EventManager();

  // Load existing events from file (if any)
  eventManager.loadEventsFromFile('eventmanager.json');

  while (true) {
    print('\n--- Event Manager ---');
    print('1. Add Event');
    print('2. Edit Event');
    print('3. Delete Event');
    print('4. List events');
    print('5. Register Attendee');
    print('6. List Attendees');
    print('7. List events chronologically');
    print('8. Check Schedule Conflict');
    print('9. Save');
    stdout.write('Choose an option: ');
    final input = stdin.readLineSync();

    switch (input) {
      case '1':
        stdout.write('Enter Event Title: ');
        String title = stdin.readLineSync()!;

        stdout.write('Enter Event DateTime (yyyy-MM-dd HH:mm): ');
        DateTime datetime = DateTime.parse(stdin.readLineSync()!);

        stdout.write('Enter Event Location: ');
        String location = stdin.readLineSync()!;

        stdout.write('Enter Event Description: ');
        String description = stdin.readLineSync()!;

        eventManager.addEvent(title, datetime, location, description);
        break;

      case '2':
        stdout.write('Enter Event Index to Edit: ');
        int eventId = int.parse(stdin.readLineSync()!);

        stdout.write('Enter New Event Title: ');
        String newTitle = stdin.readLineSync()!;

        stdout.write('Enter New Event DateTime (yyyy-MM-dd HH:mm): ');
        DateTime newDatetime = DateTime.parse(stdin.readLineSync()!);

        stdout.write('Enter New Event Location: ');
        String newLocation = stdin.readLineSync()!;

        stdout.write('Enter New Event Description: ');
        String newDescription = stdin.readLineSync()!;

        eventManager.editEvent(eventId - 1, newTitle, newDatetime, newLocation, newDescription);
        break;

      case '3':
        stdout.write('Enter Event Index to Delete: ');
        int deleteId = int.parse(stdin.readLineSync()!);
        eventManager.deleteEvent(deleteId - 1);
        break;

      case '4':
        eventManager.listEvents();
        break;

      case '5':
        stdout.write('Enter Event Index to Register Attendee: ');
        int registerEventId = int.parse(stdin.readLineSync()!);

        stdout.write('Enter Attendee Name: ');
        String attendeeName = stdin.readLineSync()!;

        Attendee attendee = Attendee(name: attendeeName);
        eventManager.registerAttendee(registerEventId - 1, attendee);
        break;

      case '6':
        stdout.write('Enter Event Index to List Attendees: ');
        int listAttendeeId = int.parse(stdin.readLineSync()!);
        eventManager.listAttendees(listAttendeeId - 1);
        break;

      case '7':
        eventManager.listEventsChronologically();
        break;

      case '8':
        stdout.write('Enter DateTime to Check Conflict (yyyy-MM-dd HH:mm): ');
        DateTime conflictDatetime = DateTime.parse(stdin.readLineSync()!);
        eventManager.checkScheduleConflict(conflictDatetime);
        break;

      case '9':
        // Save events to file
        eventManager.saveEventsToFile('eventmanager.json');
        print('Events saved successfully.');
        break;

      default:
        print('Invalid option. Please try again.');
    }
  }
}
