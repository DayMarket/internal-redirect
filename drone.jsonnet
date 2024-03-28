local nodeType = {
  type: 'um-common',
};

local mountedDockerVolume = {
  name: 'docker',
  path: '/var/run/docker.sock',
};

local mountedBuildVolume = {
  name: 'build',
  path: '/drone/src/public',
};

local dockerVolume = {
  name: 'docker',
  host: {
    path: '/var/run/docker.sock',
  },
};

local buildVolume = {
  name: 'build',
  host: {
    path: '/drone/src/public',
  },
};

local DockerfilePath = 'Dockerfile';

local buildEnviroment = {
  username: 'json_key',
  dockerfile: DockerfilePath,
  registry: 'cr.yandex',
  repo: 'cr.yandex/umarket/${DRONE_REPO_NAME}',
  use_cache: true,
  tags: '${DRONE_COMMIT_SHA:0:7}',
  password: { from_secret: 'yandex_cr_json_key' },
};


local buildDockerImage = {
  name: 'build image',
  image: 'plugins/docker',
  trusted: true,
  use_cache: true,
  volumes: [
    mountedDockerVolume,
    mountedBuildVolume,
  ],
  settings: buildEnviroment,
  event: [
    'push',
  ],
};

local build_pipeline = {
  kind: 'pipeline',
  type: 'docker',
  name: 'nuxt_pipeline_b2b_prod',
  node: nodeType,
  volumes: [
    dockerVolume,
    buildVolume,
  ],
  trigger: {
    event: {
      include: ['push', 'tag'],
      exclude: ['pull_request'],
    },
    branch: [
      'master',
    ],
  },
  steps: [
    buildDockerImage,
  ],
};

[
  build_pipeline,
]
// for push
