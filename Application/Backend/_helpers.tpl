{{- define "backend.name" -}}
backend
{{- end -}}
{{- define "backend.fullname" -}}
{{ .Release.Name }}-{{ include "backend.name" . }}
{{- end -}}