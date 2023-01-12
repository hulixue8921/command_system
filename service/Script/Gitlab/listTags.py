import gitlab
import json
import sys

res = {'code': '200', 'data': {'data': []}}
gl = gitlab.Gitlab(sys.argv[1], sys.argv[2])
lists = gl.projects.get(sys.argv[3]).tags.list()
git = gl.projects.get(sys.argv[3]).ssh_url_to_repo
for l in lists:
  res['data']['data'].append({'tagName': l.name, 'tagMessage': l.message, 'git': git})

print(json.dumps(res))

