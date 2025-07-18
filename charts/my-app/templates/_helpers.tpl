{{/* Name des Charts */}}
{{- define "my-app.name" -}}
{{- .Chart.Name -}}
{{- end }}

{{/* Vollst�ndiger Release-Name: <Release-Name>-<Chart-Name> */}}
{{- define "my-app.fullname" -}}
{{ printf "%s-%s" .Release.Name (include "my-app.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Labels f�r selector */}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
