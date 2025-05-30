# Create a new virtual environment
py -m venv .venv 

# Activate the virtual environment
source /.venv/bin/activate #Linux
.\.venv\Scripts\activate #Windows

# check the installed package versions inside the venv
py -V
pip -V

# upgrade the python version in your venv (i.e. from 3.9 to 3.13)
py -3.13 -m venv --upgrade .venv        

# working with requirements
py -m pip list # view the installed packages
py -m pip freeze > requirements.txt # generate a requirements file
py -m pip install -r requirements.txt # install the requirements

# deactivate the venv
deactivate
