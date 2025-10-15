{{- define "frontend.name" -}}
frontend
{{- end -}}
{{- define "frontend.fullname" -}}
{{ .Release.Name }}-{{ include "frontend.name" . }}
{{- end -}}