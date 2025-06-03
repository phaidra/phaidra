#!/bin/bash

# Initialize log files with proper permissions
touch /tmp/fixity-errors.log /tmp/fixity-success.log
chmod 666 /tmp/fixity-errors.log /tmp/fixity-success.log

# Function to log errors
log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> /tmp/fixity-errors.log
    # Also print to stderr for immediate visibility
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Function to log success
log_success() {
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> /tmp/fixity-success.log
    # Also print to stdout for immediate visibility
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to properly escape JSON string
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr -d '\n' | sed 's/\t/\\t/g'
}

# Log script start
log_success "Fixity handler script started"

# Validate required environment variables
required_vars=(
    "MONGODB_PHAIDRA_USER"
    "MONGODB_PHAIDRA_PASSWORD"
    "MONGODB_PHAIDRA_HOST"
    "MONGODB_PORT"
    "MONGODB_DATABASE"
    "MONGODB_COLLECTION"
    "SMTP_HOST"
    "SMTP_PORT"
    "SMTP_USERNAME"
    "SMTP_PASSWORD"
    "SMTP_FROM"
    "SMTP_TO"
)

# Print all environment variables to success log
log_success "Environment variables:"
for var in "${required_vars[@]}"; do
    log_success "$var: ${!var}"
done

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log_error "Required environment variable $var is not set"
        exit 1
    fi
done

# Read the RDF/XML content from stdin
content=$(cat)

# Extract relevant information using grep/sed/awk
resource_uri=$(echo "$content" | grep -o 'rdf:about="[^"]*"' | sed 's/rdf:about="//;s/"//' | tr -d '\n')
digest=$(echo "$content" | grep -o 'urn:sha1:[^"]*' | sed 's/urn:sha1://' | tr -d '\n')
size=$(echo "$content" | grep -o 'hasSize[^>]*>[0-9]*' | sed 's/.*>//' | tr -d '\n')

# Log extracted information
log_success "Extracted information - URI: $resource_uri, Digest: $digest, Size: $size"

# Create a timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Create JSON document for MongoDB (properly escaped)
json_doc=$(cat << EOF
{
    "timestamp": "$timestamp",
    "resource_uri": "$(escape_json "$resource_uri")",
    "digest": "$(escape_json "$digest")",
    "size": "$(escape_json "$size")",
    "raw_content": "$(escape_json "$content")"
}
EOF
)

# Log MongoDB operation attempt
log_success "Attempting to store in MongoDB..."

# Store in MongoDB using mongosh
mongosh --host "${MONGODB_PHAIDRA_HOST}" -u "${MONGODB_PHAIDRA_USER}" -p "${MONGODB_PHAIDRA_PASSWORD}" --authenticationDatabase admin "${MONGODB_DATABASE}" --eval "
db.${MONGODB_COLLECTION}.insertOne($json_doc)
" 2>> /tmp/fixity-errors.log

if [ $? -eq 0 ]; then
    log_success "Successfully stored fixity failure in MongoDB for resource: $resource_uri"
else
    log_error "Failed to store fixity failure in MongoDB for resource: $resource_uri"
fi

# Log email attempt
log_success "Attempting to send email notification..."

# Create email content
email_content=$(cat << EOF
From: ${SMTP_USERNAME}
To: ${SMTP_TO}
Subject: Fixity Check Failed
Content-Type: text/plain; charset="UTF-8"

Fixity check failed at: $timestamp

Resource URI: $resource_uri
Digest: $digest
Size: $size

This is an automated message from the Fixity Checker service.
EOF
)

# Try sending email with SMTPS
email_output=$(echo "$email_content" | curl -v --url "smtps://${SMTP_HOST}:${SMTP_PORT}" \
    --mail-from "${SMTP_USERNAME}" \
    --mail-rcpt "${SMTP_TO}" \
    --ssl \
    --user "${SMTP_USERNAME}:${SMTP_PASSWORD}" \
    --upload-file - 2>&1)

email_status=$?

if [ $email_status -eq 0 ]; then
    log_success "Successfully sent email notification for resource: $resource_uri"
else
    log_error "Failed to send email notification for resource: $resource_uri"
    log_error "Email error details: $email_output"
    
    # Try alternative method using sendmail if available
    if command -v sendmail >/dev/null 2>&1; then
        log_success "Attempting to send email using sendmail..."
        echo "$email_content" | sendmail -t
        if [ $? -eq 0 ]; then
            log_success "Successfully sent email using sendmail"
        else
            log_error "Failed to send email using sendmail"
        fi
    fi
fi

# Log script completion
log_success "Fixity handler script completed" 