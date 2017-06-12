FROM octoblu/meshblu
ADD command.coffee .
ADD process.json .
ADD run.sh .
RUN chmod +x run.sh
EXPOSE 3000

CMD ["run.sh"]
