FROM scratch
ADD ./workspace .
ENTRYPOINT ["/app"]
