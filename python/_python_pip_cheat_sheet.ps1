"""Use Pep8 for code formatting best practices 
https://peps.python.org/pep-0008/

Limit comments and docstrings to 72 characters per line

Always work in a virtual environment so that you don't clutter your 
Python environment

On Mac/Linux if you don't have access to install do not use sudo to 
install packages, as this will install them system-wide

https://pypi.org/ is a place you can go to search for available
Python packages to import

FUN FACT: PiPy used to be referred to as the 'cheese shop' in 
reference to a famous Monty Python sketch. The cheese shop in the 
sketch didn't actually sell any cheese. The joke was that the 
initial PiPy also did not really have any packages, therefore
the link to the sketch. The packages were also named as wheels
as in 'wheels of cheese'.
"""

# show installed packages and their version
pip list

# generate a list of installed packages to a requirements file
pip freeze > requirements.txt

# find detailed info on the installed package
pip show PACKAGE_NAME

# install a new package (will also install its dependencies)
pip install PACKAGE_NAME

# uninstall a package (but NOT its dependencies)
pip uninstall PACKAGE_NAME

# upgrade a package to a new version
pip install -U PACKAGE_NAME

# install a package for a specific user
python -m pip install --user PACKAGE_NAME

# list outdated packages
python -m pip list -o
