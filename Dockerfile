FROM ydkdev/ydk-py
ARG BASEPATH=/root
ARG YANG_EXPLORER_PATH=${BASEPATH}/yang-explorer
EXPOSE 8000

RUN apt-get update
RUN apt-get install --no-install-recommends -y \
		python3-dev \
		python-dev \
		python3-pip \
		python-pip \
		git \
		graphviz
RUN pip install --upgrade pip setuptools virtualenv

# Yang Explorer itself
RUN mkdir -p ${YANG_EXPLORER_PATH}
WORKDIR ${YANG_EXPLORER_PATH}
COPY . .
RUN virtualenv v
RUN . v/bin/activate
RUN pip install -r requirements.txt

# Initialize yang explorer
WORKDIR ${YANG_EXPLORER_PATH}/server
RUN mkdir -p data/users
RUN mkdir -p data/session
RUN mkdir -p data/collections
RUN mkdir -p data/annotation
RUN python manage.py migrate
RUN python manage.py setupdb
RUN python manage.py bulkupload --user guest --git https://github.com/YangModels/yang.git --dir vendor/cisco/xe/1693
RUN python manage.py bulkupload --user guest --git https://github.com/YangModels/yang.git --dir standard/ietf/RFC

CMD python manage.py runserver 0.0.0.0:8000
