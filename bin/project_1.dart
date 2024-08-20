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

  @override
  String toString() {
    return 'Title: $title\nDatetime: $datetime\nLocation: $location\nDescription: $description\nAttendees: ${attendees.length}\n';
  }

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
  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      datetime: DateTime.parse(json['datetime']),
      location: json['location'],
      description: json['description'],
    )..attendees = (json['attendees'] as List)
        .map((attendeeJson) => Attendee.fromJson(attendeeJson))
        .toList();
  }
}

// STEP 2: CREATING THE ATTENDEE CLASS
class Attendee {
  // Constructor initialization
  Attendee(this.name, {this.isPresent = false});

  String name;
  bool isPresent;

  @override
  String toString() {
    return '$name (${isPresent ? 'Present' : 'Absent'})';
  }

  // Convert Attendee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPresent': isPresent,
    };
  }

  // Create an Attendee object from a JSON map
  static Attendee fromJson(Map<String, dynamic> json) {
    return Attendee(
      json['name'],
      isPresent: json['isPresent'],
    );
  }
}

// STEP 3: CREATING THE EVENT MANAGER CLASS
class EventManager {
  List<Event> events = [];

  // Add an event
  void addEvent(Event event) {
    events.add(event);
    print('Event added successfully.');
  }

  // Edit an event
  void editEvent(int index, Event updatedEvent) {
    if (index < 0 || index >= events.length) {
      print('No event found at this index');
      return;
    }
    events[index] = updatedEvent;
    print('Event at index $index was successfully edited.');
  }

  // Delete an event
  void deleteEvent(int index) {
    if (index < 0 || index >= events.length) {
      print('No event found at this index');
      return;
    }
    events.removeAt(index);
    print('The event found at index $index has been removed from the list.');
  }

  // Get a specific event
  void getEvent(int index) {
    if (index < 0 || index >= events.length) {
      print('No event found at this index');
      return;
    }
    print(events[index]);
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

  // List all events
  void listEvents() {
    if (events.isEmpty) {
      print('No events available.');
      return;
    }
    for (var event in events) {
      print(event);
    }
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

  // Load events from file
  Future<void> loadEventsFromFile(String filePath) async {
    try {
      final jsonString = await File(filePath).readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      events = jsonData.map((e) => Event.fromJson(e)).toList();
      print('Events loaded from file.');
    } catch (e) {
      print('Error loading events from file: $e');
    }
  }

  // Save events to file
  Future<void> saveEventsToFile(String filePath) async {
    final jsonData = events.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonData);
    await File(filePath).writeAsString(jsonString);
    print('Events saved to file.');
  }
}

// STEP 4: JSON CONVERSIONS
// Save a single event to a JSON file
Future<void> saveEventToFile(String filePath, Event event) async {
  final jsonData = event.toJson();
  final jsonString = jsonEncode(jsonData);
  await File(filePath).writeAsString(jsonString);
}

// Load a single event from a JSON file
Future<Event?> loadEventFromFile(String filePath) async {
  try {
    final jsonString = await File(filePath).readAsString();
    final jsonData = jsonDecode(jsonString);
    return Event.fromJson(jsonData);
  } catch (e) {
    print("Error reading or parsing file: $e");
    return null;
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
    print('4. View Event');
    print('5. Register Attendee');
    print('6. List Attendees');
    print('7. List All Events');
    print('8. Check Schedule Conflict');
    print('9. Save changes');
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

        Event event = Event(
          title: title,
          datetime: datetime,
          location: location,
          description: description,
        );

        eventManager.addEvent(event);
        break;

      case '2':
        stdout.write('Enter Event ID to Edit: ');
        int eventId = int.parse(stdin.readLineSync()!);

        stdout.write('Enter New Event Title: ');
        String newTitle = stdin.readLineSync()!;

        stdout.write('Enter New Event DateTime (yyyy-MM-dd HH:mm): ');
        DateTime newDatetime = DateTime.parse(stdin.readLineSync()!);

        stdout.write('Enter New Event Location: ');
        String newLocation = stdin.readLineSync()!;

        stdout.write('Enter New Event Description: ');
        String newDescription = stdin.readLineSync()!;

        Event updatedEvent = Event(
          title: newTitle,
          datetime: newDatetime,
          location: newLocation,
          description: newDescription,
        );

        eventManager.editEvent(eventId, updatedEvent);
        break;

      case '3':
        stdout.write('Enter Event ID to Delete: ');
        int deleteId = int.parse(stdin.readLineSync()!);
        eventManager.deleteEvent(deleteId);
        break;

      case '4':
        stdout.write('Enter Event ID to View: ');
        int viewId = int.parse(stdin.readLineSync()!);
        eventManager.getEvent(viewId);
        break;

      case '5':
        stdout.write('Enter Event ID for Attendee Registration: ');
        int registerId = int.parse(stdin.readLineSync()!);

        stdout.write('Enter Attendee Name: ');
        String attendeeName = stdin.readLineSync()!;

        Attendee attendee = Attendee(attendeeName);

        eventManager.registerAttendee(registerId, attendee);
        break;

      case '6':
        stdout.write('Enter Event ID to List Attendees: ');
        int listId = int.parse(stdin.readLineSync()!);
        eventManager.listAttendees(listId);
        break;

      case '7':
        eventManager.listEvents();
        break;

      case '8':
        stdout.write('Enter DateTime to Check Conflict (yyyy-MM-dd HH:mm): ');
        DateTime conflictDatetime = DateTime.parse(stdin.readLineSync()!);
        eventManager.checkScheduleConflict(conflictDatetime);
        break;

      case '9':
        eventManager.saveEventsToFile('eventmanager.json');
        break;

      default:
        print('Invalid option. Please try again.');
        break;
    }
  }
}
