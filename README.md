# MoMo SMS Data Processing System

**TEAM NAME: EWDGroup-10**

## PROJECT DESCRIPTION

Our project processes MoMo SMS data in XML format, cleans and categorizes the data, stores it in a relational database, and builds a frontend interface to analyze and visualize the data.

## TEAM MEMBERS

1. IZA Prince Boaz (b.iza@alustudent.com)
2. Bodgar Kwizera (b.kwizera@alustudent.com)
3. ISHIMWE Nelson Sam (n.ishimwe7@alustudent.com)
4. Merveille Shekina Ineza (m.ineza1@alustudent.com)
5. Aime Igirimpuhwe (a.igirimpuh@alustudent.com)

## PROJECT LINKS

- **Architecture Diagram**: https://drive.google.com/file/d/1uCOOpbEXII3-q4ffLBaItsfdr0jtPCMt/view?usp=sharing
- **Scrum Board**: https://trello.com/invite/b/6964b3d3585648f7833e22ea/ATTI4f324892e534028ebd52f11ed53fbc095C7160CF/alu-ewdgroup-10

---

## DATABASE DESIGN

### Entity Relationship Diagram (ERD)

The ERD for this project can be found in `docs/erd_diagram.png` (or `docs/erd_diagram.pdf`).
Link: https://miro.com/app/board/uXjVGMI6tIM=/?share_link_id=644599661628

### Design Rationale

We designed our database to handle MoMo SMS transaction data. The database has five main tables:

**Main Tables:**
- **users**: Keeps sender and receiver info like names and phone numbers
- **transactionsCategory**: Lists different transaction types (Payment, Transfer, Withdrawal, Deposit, Bill)
- **transactions**: Stores all transaction records and connects users to categories
- **userTransaction**: Links users to transactions (needed because one transaction can have multiple users like sender and receiver)
- **systemLog**: Keeps track of what the system does and logs transaction events

**Why We Made These Choices:**
1. **Separating Users from Transactions**: We put user info in its own table so we don't repeat the same data and can have many transactions per user
2. **Many-to-Many Table**: The `userTransaction` table lets us connect multiple users to one transaction, which we need for transfers between people
3. **Foreign Keys**: We use foreign keys with CASCADE delete so when a user or transaction is deleted, related data gets cleaned up automatically
4. **Keeping Logs**: The `systemLog` table uses ON DELETE SET NULL so we keep the logs even if a transaction gets deleted
5. **Speed**: We put indexes on foreign keys and columns we search often to make queries faster

### Data Dictionary

#### users
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | User ID number |
| name | VARCHAR(100) | NOT NULL | User's name |
| phoneNumber | VARCHAR(20) | NULL | Phone number |
| email | VARCHAR(200) | NULL | Email address |

#### transactionsCategory
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Category ID number |
| name | VARCHAR(100) | NOT NULL | Category name (Payment, Transfer, etc.) |
| description | TEXT | NULL | What the category is for |

#### transactions
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Transaction ID number |
| amount | DECIMAL(10,2) | NOT NULL | How much money |
| transactionDate | DATETIME | NOT NULL | When it happened |
| status | VARCHAR(50) | NOT NULL | Status (PENDING, SUCCESS, FAILED) |
| user_id | INT | NOT NULL, FK → users(id) | Which user |
| category_id | INT | NOT NULL, FK → transactionsCategory(id) | Which category |

#### userTransaction
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | INT | PRIMARY KEY, FK → users(id) | User ID |
| transactionId | INT | PRIMARY KEY, FK → transactions(id) | Transaction ID |

#### systemLog
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Log ID number |
| logTime | DATETIME | DEFAULT CURRENT_TIMESTAMP | When it was logged |
| message | TEXT | NOT NULL | What happened |
| severity | VARCHAR(50) | NOT NULL | How serious (INFO, WARNING, ERROR) |
| transactionId | INT | NULL, FK → transactions(id) | Related transaction (if any) |

### Database Constraints and Security Rules

**Foreign Key Rules:**
- Foreign keys keep data connected correctly
- `transactions.user_id` and `transactions.category_id` use ON DELETE CASCADE (deletes related stuff)
- `userTransaction` foreign keys also use ON DELETE CASCADE
- `systemLog.transactionId` uses ON DELETE SET NULL so we keep logs even if transaction is deleted

**Data Validation:**
- Fields like name, amount, transactionDate, and status must have values
- DECIMAL(10,2) keeps money amounts correct
- VARCHAR limits stop people from putting in too much text

**Indexes:**
- Primary keys automatically get indexes
- Foreign keys get indexed too, which helps when joining tables (MySQL does this automatically)

---

## SETUP INSTRUCTIONS

### Prerequisites
- MySQL Server 8.0 or newer
- MySQL command line or any MySQL client

### Database Setup

1. **Create the database:**
   ```bash
   mysql -u your_username -p < database/database_setup.sql
   ```

2. **Or run interactively:**
   ```bash
   mysql -u your_username -p
   ```
   Then execute:
   ```sql
   source database/database_setup.sql
   ```

3. **Verify tables were created:**
   ```sql
   USE momo_db;
   SHOW TABLES;
   ```

### Sample Data

After running the setup script, you can add test data. Here's an example:

```sql
INSERT INTO users (name, phoneNumber, email) VALUES
('Alice', '250788000111', 'alice@example.com'),
('Bob', '250788000222', 'bob@example.com'),
('Charlie', '250788000333', 'charlie@example.com'),
('Diana', '250788000444', 'diana@example.com'),
('Ethan', '250788000555', 'ethan@example.com');

INSERT INTO transactionsCategory (name, description) VALUES
('Payment', 'Payment to merchants'),
('Transfer', 'Peer-to-peer money transfer'),
('Withdrawal', 'Cash withdrawal from agents'),
('Deposit', 'Deposit into wallet'),
('Bill', 'Utility bill payment');
```

---

## JSON DATA MODELING

### Overview

The JSON examples show how we turn database tables into JSON format for APIs. Check out `examples/json_schemas.json` to see:

1. **Simple Tables**: Tables like users and categories become arrays of objects
2. **Nested Data**: Transaction JSON includes user and category info inside the transaction object
3. **Combined Data**: Full transaction objects also include related log entries

### SQL to JSON Mapping

**Users Table → JSON:**
- Each row in the table becomes one JSON object
- All columns show up as properties in the JSON

**Transactions Table → JSON:**
- Instead of just `user_id`, we include the full user object
- Instead of just `category_id`, we include the full category object
- We also add related log entries as an array

**Many-to-Many Table:**
- The `userTransaction` table doesn't show up directly in JSON
- When needed, we can include arrays of users in transaction objects

### Complex JSON Example

A full transaction JSON has:
- Transaction info (id, amount, date, status)
- User details nested inside
- Category details nested inside
- System logs as an array

See `examples/json_schemas.json` for full examples.

---

## SAMPLE QUERIES

### Basic CRUD Operations

**Create (Insert):**
```sql
INSERT INTO transactions (amount, transactionDate, status, user_id, category_id)
VALUES (1500.00, '2026-01-23 15:30:00', 'SUCCESS', 1, 2);
```

**Read (Select):**
```sql
SELECT t.id, t.amount, t.status, u.name, tc.name as category
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN transactionsCategory tc ON t.category_id = tc.id
WHERE t.status = 'SUCCESS';
```

**Update:**
```sql
UPDATE transactions
SET status = 'SUCCESS'
WHERE id = 1;
```

**Delete:**
```sql
DELETE FROM users WHERE id = 5;
```

### Advanced Queries

**Total transactions by category:**
```sql
SELECT tc.name, COUNT(t.id) as transaction_count, SUM(t.amount) as total_amount
FROM transactionsCategory tc
LEFT JOIN transactions t ON tc.id = t.category_id
GROUP BY tc.id, tc.name;
```

**User transaction history:**
```sql
SELECT u.name, t.amount, t.transactionDate, t.status, tc.name as category
FROM users u
JOIN transactions t ON u.id = t.user_id
JOIN transactionsCategory tc ON t.category_id = tc.id
WHERE u.id = 1
ORDER BY t.transactionDate DESC;
```

**System logs by severity:**
```sql
SELECT severity, COUNT(*) as log_count
FROM systemLog
GROUP BY severity;
```

**Transactions with multiple users (using junction table):**
```sql
SELECT t.id, t.amount, GROUP_CONCAT(u.name) as involved_users
FROM transactions t
JOIN userTransaction ut ON t.id = ut.transactionId
JOIN users u ON ut.user_id = u.id
GROUP BY t.id, t.amount;
```

---

## REPOSITORY STRUCTURE

```
EWDGroup-10/
├── README.md                 # This file
├── database/
│   └── database_setup.sql    # Database DDL script
├── docs/
│   └── erd_diagram.png       # Entity Relationship Diagram
├── examples/
│   └── json_schemas.json     # JSON schema examples
├── api/                      # API implementation
├── etl/                      # ETL processing scripts
├── web/                      # Frontend files
└── tests/                    # Test files
```

---

## WEEK 2 DELIVERABLES CHECKLIST

- [x] ERD diagram in `docs/` folder
- [x] SQL setup script in `database/database_setup.sql`
- [x] JSON examples in `examples/json_schemas.json`
- [x] Updated README.md with database documentation
- [x] Database design rationale (included above)
- [x] Data dictionary (included above)
- [x] Sample queries (included above)
- [x] Security rules documentation (included above)

---

## NEXT STEPS

- Add sample data insertion scripts
- Add CHECK constraints for status values
- Add more indexes to speed up queries
- Build API endpoints to access the data
- Create frontend to show the data
