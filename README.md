# alog2json
Apache Combined Log Format から JSONに変換するスクリプト

# 使用例
jqをつかって、HOST, DATETIME, USER-AGENT, METHOD, URL を CSVにする

	cat access_log | ./alog2json.pl | jq -r '(.[] | [.host, .datetime, .ua, .requests.method, .requests.path] | @csv)'
