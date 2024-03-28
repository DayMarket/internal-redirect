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
  common: {
    username: 'json_key',
    dockerfile: DockerfilePath,
    registry: 'cr.yandex',
    repo: 'cr.yandex/umarket/${DRONE_REPO_NAME}',
    use_cache: true,
    password: { from_secret: 'yandex_cr_json_key' },
  },
  master: self.common {
    tags: '${DRONE_COMMIT_SHA:0:7}',
  },
  tag: self.common {
    tags: '${DRONE_TAG}',
  },
};


local buildDockerImageMaster = {
  name: 'build image',
  image: 'plugins/docker',
  trusted: true,
  use_cache: true,
  volumes: [
    mountedDockerVolume,
    mountedBuildVolume,
  ],
  settings: buildEnviroment.master,
  event: [
    'push',
  ],
};

local buildDockerImageTag = {
  name: 'build image',
  image: 'plugins/docker',
  trusted: true,
  use_cache: true,
  volumes: [
    mountedDockerVolume,
    mountedBuildVolume,
  ],
  settings: buildEnviroment.tag,
  event: [
    'push',
  ],
};

local build_pipeline_master = {
  kind: 'pipeline',
  type: 'docker',
  name: 'build master',
  node: nodeType,
  volumes: [
    dockerVolume,
    buildVolume,
  ],
  trigger: {
    event: {
      include: ['push'],
      exclude: ['pull_request'],
    },
    branch: [
      'master',
    ],
  },
  steps: [
    buildDockerImageMaster,
  ],
};

local build_pipeline_tag = {
  kind: 'pipeline',
  type: 'docker',
  name: 'build tag',
  node: nodeType,
  volumes: [
    dockerVolume,
    buildVolume,
  ],
  trigger: {
    event: {
      include: ['tag'],
      exclude: ['pull_request'],
    },
    branch: [
      'master',
    ],
  },
  steps: [
    buildDockerImageTag,
  ],
};


[
  build_pipeline_master,
  build_pipeline_tag,
]
