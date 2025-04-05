# The steps below are for linux

# generate the virtual environment file within the project folder
python3 -m venv .venv 

# activate the virtual env
source /.venv/bin/activate

# check the installed package versions inside the venv
python3 -V
pip -V

# get a listing of just the packages that are installed in the venv
python3 -m pip list

# generate a requirments file
python3 -m pip freeze > requirements.txt

# install the requirements from that file (for someone else opening this project)
python3 -m pip install -r requirements.txt

# deactivate the venv
deactivate


# If using windows then make a few adjustments to these commands:
python -m venv .venv       #create the env
.\.venv\Scripts\activate  #activate
