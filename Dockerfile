FROM docker:dind
# dind requires priviliged running, but there may be mitigation:
#
# Does rootless help?
# https://docs.docker.com/engine/security/rootless/
# Or sysbox runtime?
# Via https://devopscube.com/run-docker-in-docker/
# Eg https://github.com/nestybox/sysbox

ENV JUPYTER_TOKEN letmein

RUN apk update && apk add bash docker-compose && apk add --update --no-cache python3 gcc python3-dev linux-headers musl-dev libffi-dev g++ tini npm git && ln -sf python3 /usr/bin/python && python3 -m ensurepip && pip3 install --no-cache --upgrade pip setuptools
RUN pip install jupyter jupyterlab docker pymongo jupyter-server-proxy jupytext
# Do we need to actually install the jupyterlab server-proxy extension?
RUN jupyter labextension install @jupyterlab/server-proxy

ARG NB_USER="jovyan"

#RUN adduser -S $NB_USER
RUN adduser -S $NB_USER && addgroup jovyan root
ENV HOME=/home/$NB_USER NB_USER=$NB_USER 

COPY docker-compose.yml $HOME/docker-compose.yml

# https://github.com/gormanb/mongo-shardalyzer
# There are lots of outdate packages in this build
# Has a dependency on git Alpine package
COPY mongo-shardalyzer-master $HOME/mongo-shardalyzer-master/
RUN chmod -R ugo+rw $HOME/mongo-shardalyzer-master
#
# Can we initialise the workspace?
COPY jupyterlab-workspace.json $HOME/jupyterlab-workspace.json
COPY .jupyter/ $HOME/.jupyter/

# Copy notebooks
COPY *.ipynb $HOME/

USER root
RUN chown -R jovyan $HOME/.jupyter
USER jovyan
WORKDIR $HOME/mongo-shardalyzer-master
RUN npm install && ./node_modules/bower/bin/bower install
WORKDIR $HOME/
# https://github.com/dwmkerr/mongo-monitor
USER root
RUN npm install -g mongo-monitor


EXPOSE 8888


# JupyterLab workspaces:
# https://jupyterlab.readthedocs.io/en/stable/user/urls.html#managing-workspaces-ui
# Create a workspace file from a Jupyterlab setup
# jupyter lab workspaces export > jupyterlab-workspace.json
# Import a workspace (does JupyterLab have to be running?)
USER jovyan
RUN jupyter lab workspaces import $HOME/jupyterlab-workspace.json 
USER root
WORKDIR $HOME

# The following breaks the CMD used to start the docker daemon
#ENTRYPOINT ["tini", "-g", "--"]
#CMD ["jupyter", "notebook", "--port=8888", "--notebook-dir=/home/jovyan", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

#docker inspect -f '{{.Config.Entrypoint}}' docker:dind
#docker inspect -f '{{.Config.Cmd}}' docker:dind
# Original ENTRYPOINT set to: [dockerd-entrypoint.sh]
# Original CMD set to: [] though may be: sh?
# Related: https://github.com/docker-library/docker/issues/200
# https://github.com/docker-library/docker/tree/master/20.10-rc
# Script: https://github.com/docker-library/docker/blob/master/20.10-rc/docker-entrypoint.sh