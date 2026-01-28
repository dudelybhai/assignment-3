import argparse
import re
import json
import logging
import sys

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

JIRA_TICKET_PATTERN = r"GCC-\d+"
API_ENDPOINT = "https://jira.example.com/rest/api/2/issue"

def validate_input(text):
    """
    Validates if the text contains a valid Jira Ticket ID.
    Returns the first Ticket ID found or None.
    """
    match = re.search(JIRA_TICKET_PATTERN, text)
    if match:
        return match.group(0)
    return None

def mock_update_jira(ticket_id, comment):
    """
    Mock function to simulate updating a Jira ticket.
    """
    payload = {
        "body": comment
    }
    logger.info(f"Mocking call to Jira API: POST {API_ENDPOINT}/{ticket_id}/comment")
    logger.info(f"Payload: {json.dumps(payload, indent=2)}")
    return True

def generate_release_notes(ticket_id, commit_msg):
    """
    Generates a simple release note.
    """
    note = f"""
# Release Note
## Ticket: {ticket_id}
## Changes
{commit_msg}
    """
    return note

def main():
    parser = argparse.ArgumentParser(description="Jira Integration for GCC Pipeline")
    parser.add_argument('--title', help="Pull Request Title or Commit Message to validate")
    parser.add_argument('--comment', help="Comment to post to Jira")
    
    args = parser.parse_args()
    
    if not args.title:
        logger.error("No title provided for validation.")
        sys.exit(1)
        
    ticket_id = validate_input(args.title)
    
    if not ticket_id:
        logger.error(f"Validation FAILED. No GCC ticket ID found in title: '{args.title}'")
        sys.exit(1)
        
    logger.info(f"Validation SUCCEEDED. Found Ticket ID: {ticket_id}")
    
    if args.comment:
        mock_update_jira(ticket_id, args.comment)
        
    print(generate_release_notes(ticket_id, args.title))

if __name__ == "__main__":
    main()
