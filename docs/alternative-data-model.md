### **Table Structure**

#### **1. Dimensions Table**
The **Dimensions** table will store all hierarchical information (Account, Campaign, AdSet, Ad) in a single table. Each dimension is identified by a unique ID and includes parent-child relationships for hierarchical queries.

| Column Name       | Data Type      | Description                                      |
|--------------------|----------------|--------------------------------------------------|
| `id`              | Primary Key    | Unique identifier for each dimension.           |
| `name`            | String         | Name of the dimension (e.g., Account name).     |
| `dimension_type`  | Enum or String | Type of dimension (`Account`, `Campaign`, etc.).|
| `parent_id`       | Foreign Key    | Self-referencing key to indicate the hierarchy. |

**Example Data**:
| id  | name       | dimension_type | parent_id | attributes                    |
|-----|------------|----------------|-----------|-------------------------------|
| 1   | Account A  | Account        | NULL      | NULL                          |
| 2   | Campaign X | Campaign       | 1         | {"objective": "Traffic"}      |
| 3   | AdSet Y    | AdSet          | 2         | {"optimization_goal": "Clicks"}|
| 4   | Ad Z       | Ad             | 3         | {"ad_type": "Image Ad"}       |

#### **2. Metrics Table**
The **Metrics** table will store all numerical data (e.g., impressions, clicks, spend) and link it to the relevant dimension by a `dimension_id`.

| Column Name       | Data Type      | Description                                      |
|--------------------|----------------|--------------------------------------------------|
| `id`              | Primary Key    | Unique identifier for each metric entry.        |
| `dimension_id`    | Foreign Key    | Links to the relevant dimension.                |
| `date`            | Date           | Date for the metric entry.                      |
| `metric_name`     | String         | Name of the metric (e.g., `impressions`).       |
| `metric_value`    | Numeric        | Value of the metric.                            |

**Example Data**:
| id  | dimension_id | date       | metric_name   | metric_value |
|-----|--------------|------------|---------------|--------------|
| 1   | 2            | 2024-01-01 | impressions   | 1000         |
| 2   | 2            | 2024-01-01 | clicks        | 200          |
| 3   | 3            | 2024-01-01 | impressions   | 500          |
| 4   | 3            | 2024-01-01 | clicks        | 100          |

#### **3. User Table**
| Column Name    | Data Type   | Description                      |
|----------------|-------------|----------------------------------|
| `id`           | Primary Key | Unique identifier for the user. |
| `email`        | String      | User's email address.           |
| `password_hash`| String      | Password hash for authentication.|

---

#### **4. UserAccountMapping Table**
This table maps users to ad accounts they have access to.

| Column Name     | Data Type    | Description                           |
|-----------------|--------------|---------------------------------------|
| `id`            | Primary Key  | Unique identifier.                   |
| `user_id`       | Foreign Key  | Links to the User table.             |
| `account_id`    | Foreign Key  | Links to the Dimensions table (`Account` rows).|
| `role`          | Enum/String  | Role of the user (`admin`, `viewer`).|

---

### **Advantages of This Approach**
1. **Reduced Complexity**:
   - No need for separate tables for Accounts, Campaigns, AdSets, and Ads.
   - Hierarchical relationships can be inferred using `parent_id`.

2. **Scalability**:
   - Adding new types of dimensions (e.g., "Creative") or metrics (e.g., "Engagement Rate") is easy.

3. **Flexibility for Queries**:
   - Dynamic SQL queries can aggregate metrics and group by dimensions flexibly.

---

### **Query Patterns**

1. **Get Total Impressions by Campaign**
   ```sql
   SELECT 
       d.name AS campaign_name, 
       SUM(m.metric_value) AS total_impressions
   FROM metrics m
   JOIN dimensions d ON m.dimension_id = d.id
   WHERE d.dimension_type = 'Campaign'
     AND m.metric_name = 'impressions'
     AND m.date BETWEEN '2024-01-01' AND '2024-01-31'
   GROUP BY d.name;
   ```

2. **Get Spend by AdSet for a Specific Campaign**
   ```sql
   SELECT 
       d.name AS adset_name, 
       SUM(m.metric_value) AS total_spend
   FROM metrics m
   JOIN dimensions d ON m.dimension_id = d.id
   WHERE d.dimension_type = 'AdSet'
     AND d.parent_id = (SELECT id FROM dimensions WHERE name = 'Campaign X' AND dimension_type = 'Campaign')
     AND m.metric_name = 'spend'
     AND m.date BETWEEN '2024-01-01' AND '2024-01-31'
   GROUP BY d.name; 
   ```

3. **Hierarchical Aggregations**
   To aggregate across hierarchical levels (e.g., Account → Campaign → AdSet), use recursive CTEs (Common Table Expressions) to navigate the parent-child relationships.

   ```sql
   WITH RECURSIVE dimension_hierarchy AS (
       SELECT id, name, dimension_type, parent_id
       FROM dimensions
       WHERE id = 1  -- Start from a specific account
       UNION ALL
       SELECT d.id, d.name, d.dimension_type, d.parent_id
       FROM dimensions d
       JOIN dimension_hierarchy dh ON d.parent_id = dh.id
   )
   SELECT 
       dh.name AS dimension_name, 
       dh.dimension_type,
       SUM(m.metric_value) AS total_metric_value
   FROM dimension_hierarchy dh
   JOIN metrics m ON m.dimension_id = dh.id
   WHERE m.metric_name = 'impressions'
   GROUP BY dh.name, dh.dimension_type;
   ```

### Critique of the Two-Table Approach

#### **Advantages**
1. **Simplicity**:
   - Consolidates hierarchical data into a single table, making storage straightforward.
2. **Scalability**:
   - Flexible to add new types of dimensions and metrics without schema changes.
3. **Query Flexibility**:
   - Works well for dynamic queries based on the selectors (dates, dimensions, metrics).

#### **Limitations**
1. **Complex Queries**:
   - Hierarchical queries require recursive CTEs or application-level logic, which can become computationally expensive.
   - Aggregations across multiple levels can lead to slower performance for large datasets.
2. **Denormalized Metrics**:
   - Storing each metric as a separate row in the `Metrics` table (instead of columns) simplifies extensibility but can complicate querying and indexing.
3. **Potential Overhead**:
   - Storing metadata (e.g., attributes) in JSON fields can result in performance overhead for frequent lookups or aggregations.
4. **User-to-Account Mapping**:
   - Requires additional tables (e.g., `UserAccountMapping`) to handle multi-user access and permissions, which adds complexity to the backend logic.
5. **Indexing**:
   - Performance heavily depends on appropriate indexing of fields like `dimension_id`, `date`, and `metric_name`. Without careful design, queries on large datasets will be slow.

---