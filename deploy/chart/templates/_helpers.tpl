{{/* Default labels for chart. */}}
{{- define "pkg.labels" -}}
app: vault-controller
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}
