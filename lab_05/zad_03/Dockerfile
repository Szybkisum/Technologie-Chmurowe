ARG python_version="latest"
FROM python:${python_version}

WORKDIR /myapp
COPY /myapp ./
RUN pip install -r requirements.txt
CMD [ "python3", "app.py" ]
