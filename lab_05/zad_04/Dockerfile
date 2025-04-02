ARG python_version="latest"

FROM python:${python_version}-alpine

ARG port=8080
ENV port=${port}

WORKDIR /myapp
COPY /myapp ./
RUN pip install -r requirements.txt
EXPOSE ${port}
VOLUME ["/app/data"]
CMD [ "python3", "app.py" ]
