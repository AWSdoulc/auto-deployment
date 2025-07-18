{{/* Chart-Version (Name-Version) */}}
{{- define "my-app.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/* Chart-Name */}}
{{- define "my-app.name" -}}
{{- .Chart.Name -}}
{{- end }}

{{/* Vollständiger Release-Name */}}
{{- define "my-app.fullname" -}}
{{ printf "%s-%s" .Release.Name (include "my-app.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Selector-Labels */}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Standard-Labels für alle Ressourcen */}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
