FROM haproxy

EXPOSE 80
EXPOSE 1883
EXPOSE 3000

ADD ./deployments/docker/haproxy/run.sh .
ADD ./deployments/docker/haproxy/haproxy.cfg .
CMD ["./run.sh"]