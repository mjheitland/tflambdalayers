# Terraform project to deploy lambda function with lambda layer

Simple lambda function 'mylambda' that calls 'custom_func' and sends a http request using the Python library 'requests'.
Both 'custom_func' and 'requests' library are in a Lambda layer.
Output in CloudWatch.

## Create lambda layer with all the needed Python libraries

We are setting up a virtual Python environment that uses the desired Python version and libraries

[How to create a Python Lambda Layer](https://medium.com/brlink/how-to-create-a-python-layer-in-aws-lambda-287235215b79)

[pyenv documentation](https://github.com/pyenv/pyenv#basic-github-checkout)

[pyenv commands](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md)

```Bash
# Install pyenv
brew install openssl readline sqlite3 xz zlib pyenv
echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Restart shell!!!

# Install Python versions (installed into ~/.pyenv/versions/)
pyenv install --list | grep " 3\.*"
pyenv install -v 2.7.16
pyenv install -v 3.8.12
pyenv install -v 3.9.10
python -m test # to check that this version works properly
# pyenv uninstall 3.8.12

# Set global Python version
pyenv global 3.9.10 # use now python 3.9.10 globally
python -V

# Set local Python version
pyenv local 3.8.12 # use now python 3.8.12 in current shell
python -V
pyenv versions # or 'ls ~/.pyenv/versions/'

# Create virutal environment
python -m venv .venv # in Python 2: virtualenv .venv
source .venv/bin/activate

# Install all necessary packages that shall be included to the layer (e.g. 'requests')
pip install requests -t temp

# Move all files from 'temp' to 'layers/python/lib/python3.8/site-packages/'

# Leave virtual environment
deactivate
```

## Deploy Lambda with Terraform

```
terraform init
terraform apply -auto-approve
```

## Teardown with Terraform

```
terraform destroy -auto-approve
```
