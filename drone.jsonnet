local pipeline(name) = {
  kind: 'pipeline',
  type: 'docker',
  name: name,
  node: {
    type: 'um-common',
  },
  withTrigger(trigger):: self + {
    trigger: trigger,
  },
  withVolumes(volumes):: self + {
    volumes: volumes,
  },
  withServices(services):: self + {
    services: services,
  },
  withSteps(steps):: self + {
    steps: steps,
  },
};

local step(name, image) = {
  name: name,
  image: image,
  withCommands(commands):: self + {
    commands: commands,
  },
  withWhen(when):: self + {
    when: when,
  },
  withVolumes(volumes):: self + {
    volumes: volumes,
  },
  withEnvs(envs):: self + {
    environment: envs,
  },
  withDeps(deps):: self + {
    depends_on: deps,
  },
  withSettings(settings):: self + {
    settings: settings,
  },
};

local buildAndPublishImage(name, repo, tags, dockerfile, secret) =
  step(name, 'plugins/gcr')
  .withSettings({
    username: 'json_key',
    registry: 'cr.yandex',
    repo: 'cr.yandex/' + repo,
    tags: tags,
    purge: false,
    password: { from_secret: secret },
    dockerfile: dockerfile,
  })
  .withEnvs({
    GITHUB_PRIVATE_REPO_TOKEN: { from_secret: 'go_private_repo_gh_token' },
  })
  .withVolumes([{ name: 'docker', path: '/var/run/docker.sock' }]);

local volumes = [
  { name: 'docker', host: { path: '/var/run/docker.sock' } },
];


local production =
  pipeline('production')
  .withTrigger({
    ref: 'refs/tags/v*',
    event: ['tag'],
  })
  .withTrigger({
    ref: 'refs/heads/master',
    event: ['push'],
  })
  .withVolumes(volumes)
  .withSteps([
    buildAndPublishImage(
      name='build and publish image uzum',
      repo='umarket/' + '${DRONE_REPO_NAME,,}',
      tags=['${DRONE_TAG}', 'latest'],
      dockerfile='Dockerfile',
      secret='yandex_cr_json_key'
    ),
  ]);

[
  production,
]
