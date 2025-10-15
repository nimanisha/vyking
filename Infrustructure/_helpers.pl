{{- define "mysql.name" -}}
mysql
{{- end -}}

{{- define "mysql.fullname" -}}
{{ .Release.Name }}-mysql
{{- end -}}
