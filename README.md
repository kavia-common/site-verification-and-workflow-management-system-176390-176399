# site-verification-and-workflow-management-system-176390-176399

Database (PostgreSQL) Setup - Port 5001

1) Configure environment
- Navigate to postgresql_database/
- Copy .env.example to .env and adjust if necessary
  - POSTGRES_HOST=localhost
  - POSTGRES_PORT=5001
  - POSTGRES_DB=myapp
  - POSTGRES_USER=appuser
  - POSTGRES_PASSWORD=dbuser123
  - POSTGRES_URL=postgres://appuser:dbuser123@localhost:5001/myapp

2) Start PostgreSQL on port 5001
- From the postgresql_database directory:
  - bash startup.sh
- The script initializes (if needed) and starts PostgreSQL bound to port 5001.
- It also writes:
  - db_visualizer/postgres.env
  - db_connection.txt

3) Verify the connection
- Use the generated connection command stored in db_connection.txt
  - cat postgresql_database/db_connection.txt
  - Example: psql postgresql://appuser:dbuser123@localhost:5001/myapp
- Or connect with:
  - psql -h localhost -U appuser -d myapp -p 5001

4) Optionally load seed data
- After Django migrations create the required tables, you can seed sample data:
  - From the postgresql_database directory:
    - psql postgresql://appuser:dbuser123@localhost:5001/myapp -f seed.sql
- The seed includes sample rows for:
  - sites
  - workflow_steps
  - verifications
  - audit_logs

Notes
- Ensure Django migrations are applied before running seed.sql so the target tables exist.
- The Node.js simple DB viewer can be used by sourcing db_visualizer/postgres.env then starting the viewer (see db_visualizer/).