FROM alpine:latest as base
RUN apk add --no-cache --update ca-certificates


FROM scratch
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ADD kube-vault-controller /kube-vault-controller
ENTRYPOINT ["/kube-vault-controller"]
