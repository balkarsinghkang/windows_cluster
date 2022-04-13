# windows_cluster

Chef cookbook to install and configure a Windows Failover Cluster Server for CNB.

## Table of contents

1. [Usage](#usage)
1. [Attributes](#attributes)
1. [Recipes](#recipes)
1. [Resources](#resources)


## Usage

## Attributes

Attributes in this cookbook:

Name                                              | Types  | Description                                 | Default
------------------------------------------------- | ------ | --------------------------------------------| -------
# TODO: Update the attributes
`['windows_failover_cluster']['run_as_user']`     | String | Sets the default cluster user for resources | `nil`
`['windows_failover_cluster']['run_as_password']` | String | Sets the default cluster user password      | `nil`

Setting these attributes allows you skip the `run_as_user` and `run_as_password` properties when using this cookbook's resources.

## Recipes

This cookbook doesn't ship any recipes.

## Resources

### `windows_failover_cluster_node`

It creates a new Windows Failover Cluster or joins an existing cluster.

#### Actions

- `create` - (default) Creates a new Windows Failover Cluster.
- `join` - Joins a node to an existing cluster.

#### Syntax

```ruby
windows_failover_cluster_node 'name' do
  cluster_ip                 String # required when using :create action
  cluster_name               String # default value: 'name' unless specified
  install_tools              true, false # default value: true
  fs_witness                 String
  quorum_disk                String
  run_as_password            String # default value: node['windows_failover_cluster']['run_as_password']
  run_as_user                String # default value: node['windows_failover_cluster']['run_as_user']
  action                     Symbol # defaults to :create if not specified
end
```

#### Examples

Create a cluster using a quorum disk:

```ruby
windows_failover_cluster_node 'Cluster1' do
  cluster_ip '192.168.10.10'
  quorum_disk 'Cluster Disk 1'
  action :create
end
```

Create a cluster using a file share witness:

```ruby
windows_failover_cluster_node 'Cluster1' do
  cluster_ip '192.168.10.10'
  fs_witness '\\\\fileserver\\witness'
  action :create
end
```

Join an existing cluster:

```ruby
windows_failover_cluster_node 'Cluster1' do
  action :join
end
```

### `windows_failover_cluster_generic_service`

It creates a generic service for a Windows Failover Cluster.

#### Actions

- `create` - (default) Creates a new Windows Failover Cluster Generic Service.

#### Syntax

```ruby
windows_failover_cluster_generic_service 'name' do
  service_name               [Array, String] # default value: 'name' unless specified
  checkpoint_key             [Array, String]
  role_name                  String # required
  run_as_password            String # default value: node['windows_failover_cluster']['run_as_password']
  run_as_user                String # default value: node['windows_failover_cluster']['run_as_user']
  service_ip                 String # required
  storage                    String
  action                     Symbol # defaults to :create if not specified
end
```

#### Examples

Create a generic cluster service:

```ruby
windows_failover_cluster_generic_service 'Service1' do
  role_name 'Role1'
  service_ip '192.168.10.20'
  storage 'Cluster Disk 1'
  action :create
end
```