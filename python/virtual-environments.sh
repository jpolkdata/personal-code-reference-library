# generate the virtual environment file within the project folder
python -m venv .venv

# activate the virtual env
.\.venv\Scripts\activate

# check the installed package versions inside the venv
python -V
pip -V

# get a listing of just the packages that are installed in the venv
python -m pip list

# generate a requirments file
python -m pip freeze

# install the requirements from that file (for someone else opening this project)
python -m pip install -r requirements.txt

# deactivate the venv
deactivate