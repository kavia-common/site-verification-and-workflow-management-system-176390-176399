# PostgreSQL Database

Port
- Exposed on 5001 for local and preview environments.

Connection
- See db_connection.txt for a ready-to-use psql connection string.
- Example DSN: postgresql://appuser:dbuser123@localhost:5001/myapp

Notes
- Ensure the backend .env points to host=localhost and port=5001.
