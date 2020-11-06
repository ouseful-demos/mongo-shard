# mongo demo

Demon container for creating mongo sharded network:

- dind (Docker in Docker) https://devopscube.com/run-docker-in-docker/
- mongo sharded demo using docker-compose https://blog.skbali.com/2019/05/mongodb-replica-set-using-docker-compose/
- network partitioning (old) https://gist.github.com/psychemedia/67a1c27ae1b0f0cee7ef



```
docker run  --privileged  --name mtest6  -d -p 8867:8888  mongotest
docker exec -it --user jovyan mtest6 jupyter notebook --port=8888 --notebook-dir=/home/jovyan --no-browser --ip=0.0.0.0 --allow-root &
```

Then we can go to eg `http://localhost:8867/terminals/1` and run:

`docker-compose up -d`


The following currently does run but doesn't connect:
`mongo-monitor localhost:30001`

docker-py docs: https://docker-py.readthedocs.io/en/stable/

