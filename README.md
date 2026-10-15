# Gatherly — Online Event Management

Gatherly is a standalone Java web app for event organizers, attendees, and administrators. It uses the same `jm` setup and run workflow as the sibling VolunteerHub project, with an independent schema and database.

## Stack

- Java 11+, Java Servlets, Maven, and Tomcat 9
- Plain HTML, CSS, and JavaScript
- MySQL 8 with JDBC
- BCrypt password hashes and server-side sessions

## Setup and run

Install a JDK 11+ and MySQL 8. From this folder, use the included launcher:

```bat
jm init
jm migrate event_mgr_db
jm run
```

On Windows, `jm.cmd` is also available if `jm` is not on PATH. `jm init` downloads Maven and Tomcat 9 into the ignored `.jm` folder when needed, then sets the current user's `MAVEN_HOME`, `M2_HOME`, `CATALINA_HOME`, and `TOMCAT_HOME` variables and adds their `bin` folders to PATH. Restart VS Code after initialization so new terminals load those settings. `jm migrate` creates the database, applies `database/schema.sql`, provisions the application account, and writes local credentials to `src/main/resources/db.properties`. MySQL administrator credentials are requested by the migration command. `jm run` builds `target/main.war`, deploys it to Tomcat, and opens the app. You can also pass an explicit WAR name, such as `jm run main.war`.

Set `JM_DB_ADMIN_USER` if your MySQL administrator is not `root`. Set both `DB_USER` and `DB_PASSWORD` to use an existing application account. `DB_URL`, `DB_USER`, and `DB_PASSWORD` can also override the app configuration at runtime. Keep `db.properties` private; it is included in the built WAR.

## First sign-in

- Email: `admin@eventmgr.local`
- Password: `Admin@123`

`jm migrate` creates this administrator if `admin@eventmgr.local` is not already present. On first sign-in, the bootstrap credential is immediately replaced with a BCrypt password hash. Change the password after signing in and create organizer/attendee accounts. Public registration is enabled by default. If that email already exists, migration preserves its password.

## Included workflows

| Role | Main features |
| --- | --- |
| Admin | Manage users and roles, suspend/reactivate accounts, review event submissions, update system settings, view event and ticket statistics |
| Organizer | Create and edit events with date, time, venue, category, and ticket price/quantity; see registrations; send updates to registered attendees |
| Attendee | Discover approved events, reserve a ticket, view registration history, receive event updates, and edit profile details |

New events require admin approval by default. Admins can turn that setting off. Ticket reservations update seat availability and are tracked against the organizer's sales statistics. This project does not connect to a payment processor; ticket checkout is a local demo flow and does not charge a card.

## API overview

- Auth: `GET /api/auth/me|settings`, `POST /api/auth/login|register|logout`
- Admin: `/api/admin/users`, `/api/admin/events`, `/api/admin/settings`, `/api/admin/stats`
- Organizer: `/api/org/events`, `/api/org/attendees`, `/api/org/updates`
- Attendee: `/api/attendee/events`, `/api/attendee/registrations`, `/api/attendee/updates`, `/api/attendee/profile`

API areas require the matching signed-in role. Passwords are BCrypt-hashed, and active account status is checked on every API request.
