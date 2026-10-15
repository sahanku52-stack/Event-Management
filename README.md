# EventX

EventX is a Java-based event management web application designed for three user roles: administrators, organizers, and attendees. The application allows organizers to create and manage events, admins to review and approve events, and attendees to browse approved events, reserve tickets, and receive updates.

This project is built as a Java Servlet application with a MySQL-backed data layer and a lightweight front-end using HTML, CSS, and JavaScript.

## Features

### Admin features
- Manage users and roles
- Suspend or reactivate accounts
- Review and approve or reject event submissions
- Configure platform settings such as registration and approval requirements
- View platform statistics including total registrations and revenue
- Review recent activity logs

### Organizer features
- Create new events with title, description, date, time, venue, category, and ticket details
- Edit or delete existing events
- Submit events for approval when the approval workflow is enabled
- Track attendee registrations for events
- Send announcements to registered attendees
- Monitor ticket sales and event status

### Attendee features
- Browse approved events
- View event details and ticket information
- Reserve tickets for open events
- View registration history
- Cancel confirmed registrations
- Update profile information
- Receive organizer announcements for registered events

### Security and platform behavior
- Role-based access control via servlet API endpoints
- Session-based authentication
- BCrypt password hashing
- Account status checks for suspended users
- Default admin bootstrap account created during project setup

## Technologies used

- Java 11+
- Java Servlets / Jakarta-style servlet APIs
- Apache Maven
- Apache Tomcat 9
- MySQL 8
- JDBC for database access
- Google Gson for JSON handling
- jBCrypt for password hashing
- HTML, CSS, and JavaScript for the front-end

## System requirements

Before running the project, make sure you have:

- JDK 11 or newer
- MySQL 8.x
- Maven (the project includes a local launcher, but Java and MySQL are still required)
- Tomcat 9 or compatible servlet container
- A modern browser

## Installation and setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd Event_mgr
```

### 2. Initialize the local project toolchain

This project includes a custom launcher script for setup and deployment:

```bat
jm.cmd init
```

On a Unix-like system, the equivalent command is:

```bash
./jm init
```

This initializes the local Maven and Tomcat setup in the `.jm` folder if it is not already available.

### 3. Configure the database

Create a MySQL database and configure access credentials.

The project expects a `db.properties` file in `src/main/resources/` or environment variables such as:

- `DB_URL`
- `DB_USER`
- `DB_PASSWORD`

Example configuration:

```properties
db.url=jdbc:mysql://localhost:3306/event_mgr_db?useSSL=false&serverTimezone=UTC
db.user=root
db.password=your_password
```

### 4. Run the database migration

```bat
jm.cmd migrate event_mgr_db
```

This command uses the project schema and creates the required tables and default settings.

### 5. Run the application

```bat
jm.cmd run
```

This builds the WAR file and deploys it using the local Tomcat setup.

## Default admin account

The application creates a default administrator if one does not already exist.

- Email: `admin@eventmgr.local`
- Password: `Admin@123`

On the first login, the bootstrap password is replaced with a BCrypt hash for security. It is recommended that you change this password after the first sign-in.

## Project structure

```text
Event_mgr/
├── database/
│   └── schema.sql
├── src/
│   ├── main/
│   │   ├── java/com/eventmgr/
│   │   │   ├── util/
│   │   │   └── web/
│   │   ├── resources/
│   │   └── webapp/
│   └── test/
├── pom.xml
├── jm.cmd
├── README.md
├── .jm/
└── target/
```

## API overview

The application exposes REST-style servlet endpoints grouped by role:

- Auth:
  - `GET /api/auth/me`
  - `GET /api/auth/settings`
  - `POST /api/auth/login`
  - `POST /api/auth/register`
  - `POST /api/auth/logout`
- Admin:
  - `GET /api/admin/users`
  - `GET /api/admin/events`
  - `GET /api/admin/settings`
  - `GET /api/admin/stats`
- Organizer:
  - `GET /api/org/events`
  - `GET /api/org/attendees`
  - `GET /api/org/updates`
- Attendee:
  - `GET /api/attendee/events`
  - `GET /api/attendee/registrations`
  - `GET /api/attendee/updates`
  - `GET /api/attendee/profile`

## Future improvements

The current project is a solid demo/event-management foundation, and the following enhancements would be useful:

- Payment integration for paid ticketing
- Email notifications and reminders
- PDF ticket generation
- Event calendar and filtering improvements
- Dashboard charts for organizers and admins
- Better reporting and export features
- REST documentation via Swagger/OpenAPI
- Improved admin analytics and audit controls

## Author

Developed as a Java Project for the GUVI-Galgotias Project Board.

## License

This project is intended for educational purposes.


