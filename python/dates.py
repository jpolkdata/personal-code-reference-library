from datetime import datetime, timedelta
# import dateutil.parser as parser

date = datetime.now()

print('== CONVERT A DATETIME TO A FORMATTED STRING ==')
print(f'Current datetime: {date}')
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S%f')
print(f'Converted to string: {timestamp}')
print()

print('== CONVERT A STRING TO A DATETIME ==')
date_str = "2023-01-01 14:00"
print(f'String: {date_str}')
date_parsed = datetime.strptime(date_str, '%Y-%m-%d %H:%M') # This format must match the input exactly
print(f'Parsed: {date_parsed}')
print()

print('== DATE MATH ==')
print(f'Current datetime: {date}')
print(f'Add 10 minutes: {date - timedelta(minutes=10)}')
print(f'Add 10 hours: {date - timedelta(hours=10)}')
print(f'Add 10 days: {date - timedelta(days=10)}')
print()
