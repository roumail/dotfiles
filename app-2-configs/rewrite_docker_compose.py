import yaml
import sys

# Get the input and output file paths from command-line arguments
input_file = sys.argv[1]
output_file = sys.argv[2]

# Load the original docker-compose file
with open(input_file, 'r') as f:
    compose = yaml.safe_load(f)

# Remove all 'ports' and volumes sections
for service in compose['services'].values():
    if 'ports' in service:
        del service['ports']
    if 'volumes' in service:
        del service['volumes']
    

# Write the modified content to a new file
with open(output_file, 'w') as f:
    yaml.dump(compose, f, default_flow_style=False)