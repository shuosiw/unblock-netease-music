FROM alpine:latest

COPY UnblockNeteaseMusic/* /root/app/
COPY service.sh /root/app/
RUN chmod +x /root/app/service.sh

EXPOSE 80 443

CMD ["/root/app/service.sh"]
