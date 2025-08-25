#!/bin/bash

# Usage: ./import_high_fives.sh input.csv dbname

CSV_FILE="$1"
DB_NAME="high_fives_experiment"
TABLE_NAME="high_fives"

if [[ -z "$CSV_FILE" || -z "$DB_NAME" ]]; then
  echo "Usage: $0 input.csv dbname"
  exit 1
fi

# Read the first line of the CSV (headers)
HEADER_LINE=$(head -n 1 "$CSV_FILE" | tr -d '\r')

# Split headers into array
IFS=',' read -r -a RAW_HEADERS <<< "$HEADER_LINE"

SANITIZED_HEADERS=()
for h in "${RAW_HEADERS[@]}"; do
  # Lowercase, replace non-alphanumeric with underscores
  clean=$(echo "$h" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g')
  # Trim leading/trailing underscores
  clean=$(echo "$clean" | sed -E 's/^_+|_+$//g')
  # Ensure it's not empty
  if [[ -z "$clean" ]]; then
    clean="col_${#SANITIZED_HEADERS[@]}"
  fi
  SANITIZED_HEADERS+=("$clean")
done

# Build SQL column definition string
COLUMNS=$(printf '"%s" TEXT, ' "${SANITIZED_HEADERS[@]}")
COLUMNS=${COLUMNS%, } # remove trailing comma

echo "Creating database $DB_NAME (if not exists)..."
createdb "$DB_NAME" 2>/dev/null || echo "Database already exists."

echo "Dropping old table (if exists)..."
psql -d "$DB_NAME" -c "DROP TABLE IF EXISTS $TABLE_NAME;"

echo "Creating table $TABLE_NAME with ${#SANITIZED_HEADERS[@]} columns..."
psql -d "$DB_NAME" -c "CREATE TABLE $TABLE_NAME ($COLUMNS);"

echo "Importing data from $CSV_FILE..."
psql -d "$DB_NAME" -c "\copy high_fives FROM $CSV_FILE WITH CSV HEADER QUOTE '\"' ESCAPE '\"' ENCODING 'UTF8';"

echo "Done! Imported data into $DB_NAME.$TABLE_NAME"

echo -e
echo "--------------------------------------------------"

total_high_fives=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    count(*)
  FROM
    high_fives;
" -t -A)

echo -e
echo "There are $total_high_fives high fives."

first_high_five=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    min(date_submitted)
  FROM
    high_fives;
" -t -A)
first_high_fiver=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    (first_name || ' ' || last_name)
  FROM
    high_fives
  ORDER BY
    date_submitted ASC
  LIMIT 1;
" -t -A)
echo -e
echo "The first was created on $first_high_five by $first_high_fiver."

last_high_five=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    max(date_submitted)
  FROM
    high_fives;
" -t -A)
last_high_fiver=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    (first_name || ' ' || last_name)
  FROM
    high_fives
  ORDER BY
    date_submitted DESC
  LIMIT 1;
" -t -A)
echo -e
echo "The last was created on $last_high_five by $last_high_fiver."

top_high_fivers=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    creator as \"High Fiver\",
    COUNT(*) as \"High Fives Given\"
  FROM
    high_fives
  GROUP BY
    creator
  ORDER BY
    COUNT(creator) DESC
  LIMIT 10;
" -A)
echo -e
echo "The most prolific high fivers are:"
echo -e
column -t -s'|' <<<"$top_high_fivers"

top_high_five_receivers=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    (first_name || ' ' || last_name) as \"Receiver\",
    COUNT(first_name || ' ' || last_name) as \"High Fives Received\"
  FROM
    high_fives
  GROUP BY
    first_name,
    last_name
  ORDER BY
    COUNT(creator) DESC
  LIMIT 10;
" -A)
echo -e
echo "The top high five receivers are:"
echo -e
column -t -s'|' <<<"$top_high_five_receivers"

top_unique_receivers=$(psql -U postgres -d $DB_NAME -c "
  SELECT
    (first_name || ' ' || last_name) AS \"Receiver\",
    COUNT(DISTINCT creator) AS \"Unique High Fivers\",
    (
      SELECT
        COUNT(DISTINCT creator)
      FROM
        high_fives
    ) AS \"Total High Fivers\"
  FROM
    high_fives
  GROUP BY
    \"Receiver\"
  ORDER BY
    \"Unique High Fivers\" DESC
  LIMIT 10;
" -A)
echo -e
echo "The people who have been high fived by the most unique people are:"
echo -e
column -t -s'|' <<<"$top_unique_receivers"

echo "--------------------------------------------------"

# -- High fives received grouped by year
# SELECT (first_name || ' ' || last_name) as receiver, COUNT(first_name || ' ' || last_name) as high_fives_received, date_part('year', date_submitted::TIMESTAMP) as date_submitted_year FROM high_fives GROUP BY receiver, date_part('year', date_submitted::TIMESTAMP) ORDER BY date_part('year', date_submitted::TIMESTAMP), high_fives_received ASC;
