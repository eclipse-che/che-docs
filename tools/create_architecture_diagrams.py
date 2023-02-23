#!/bin/env python3
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
"""
Generate architecture diagrams
"""

from diagrams import *
from diagrams.custom import Custom
from diagrams.k8s.controlplane import APIServer
from diagrams.k8s.rbac import User
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.network import Traefik
from diagrams.onprem.vcs import Git
from diagrams.outscale.compute import Compute
from diagrams.outscale.storage import SimpleStorageService


def architecture_diagrams(prod_short, project_context, orchestrator_name):
    """

    :param prod_short: Short product name
    :param project_context: project-context AsciiDoc attribute value
    :param orchestrator_name: Orchestrator name
    """
    script_path = os.path.dirname(os.path.realpath(__file__))
    file_path = script_path + '/../build/collector/architecture-diagrams/' + project_context + '-'
    prod_icon = script_path + '/' + project_context + '-icon.png'
    graph_attr = {
        "bgcolor": "white",
        "layout": "dot",
        "overlap": "false",
        # "splines": "curved"
    }

    filename = file_path + 'interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 graph_attr=graph_attr):
        devfile = Git('Devfile v2')
        dashboard = Custom('User dashboard', prod_icon)
        with Cluster(orchestrator_name + ' API'):
            devworkspace_operator = Compute('DevWorkspace')
            workspace = Compute('User workspace')
        devfile >> dashboard >> devworkspace_operator >> workspace

    filename = file_path + 'deployments-interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr
                 ):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_gateway = Traefik('Gateway')
        devfile_registries = SimpleStorageService('Devfile registries')
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        git = Git('Git provider')
        postgres = PostgreSQL('PostgreSQL')
        plugin_registry = SimpleStorageService('Plug-in registry')
        kubernetes_api = APIServer(orchestrator_name + ' API')
        user = User('User browser')
        user >> che_gateway
        che_gateway >> [che_dashboard, devfile_registries, che_host,
                        plugin_registry, kubernetes_api]
        che_host >> [postgres, git]

    filename = file_path + 'gateway-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        user = User('User')
        che_gateway = Traefik('Gateway')
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        devfile_registries = SimpleStorageService('Devfile registry')
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        plugin_registry = SimpleStorageService('Plug-in registry')
        user_workspace = Compute('User workspaces')
        user >> che_gateway >> [
            che_dashboard, che_host, devfile_registries, plugin_registry, user_workspace]

    filename = file_path + 'dashboard-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        devfile_registry = SimpleStorageService('Devfile registries')
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        plugin_registry = SimpleStorageService('Plug-in registry')
        crd_workspace = APIServer(orchestrator_name + ' API')
        che_dashboard >> che_host,
        che_dashboard >> [
            devfile_registry, plugin_registry]
        che_dashboard >> crd_workspace

    filename = file_path + 'server-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = PostgreSQL('PostgreSQL')
        git_provider = Git('Git provider')
        crd_workspace = APIServer('API')
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_dashboard >> che_host
        che_host >> [git_provider]
        che_host >> crd_workspace
        che_host >> postgres

    filename = file_path + 'devfile-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        devfile_registry = SimpleStorageService('Devfile registries')
        che_dashboard >> devfile_registry

    filename = file_path + 'plugin-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        plugin_registry = SimpleStorageService('Plug-in registry')
        che_dashboard >> plugin_registry

    filename = file_path + 'user-workspaces-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 graph_attr=graph_attr):
        che_gateway = Traefik('Gateway')
        git = Git('Git provider')
        container_registries = SimpleStorageService('Container registries')
        artifact_management = SimpleStorageService('Dependency provider')

        user = User('User')
        user_workspace = Compute('User workspaces')
        user >> che_gateway >> user_workspace
        user_workspace >> [git, container_registries, artifact_management]


architecture_diagrams(project_context='che',
                      prod_short='Che',
                      orchestrator_name='Kubernetes')

architecture_diagrams(project_context='devspaces',
                      prod_short='Dev Spaces',
                      orchestrator_name='OpenShift')
