#!/bin/env python
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

from diagrams import *
import diagrams
from diagrams.azure.compute import Workspaces
from diagrams.custom import Custom
from diagrams.k8s.controlplane import APIServer
from diagrams.k8s.rbac import User, Role
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.network import Traefik
from diagrams.onprem.vcs import Git
from diagrams.outscale.storage import SimpleStorageService
import os


def ArchitectureDiagrams(prod_short, project_context, orch_name):
    script_path = os.path.dirname(os.path.realpath(__file__))
    file_path = script_path + \
        '/../modules/administration-guide/images/architecture/' + project_context + '-'
    prod_icon = script_path + '/' + project_context + '-icon.png'
    graph_attr = {
        "bgcolor": "white",
        "layout": "dot",
        "overlap": "false",
        "splines": "curved"
    }
    # Use neato for more complex diagrams
    graph_attr_neato = {
        "bgcolor": "white",
        "layout": "neato",
        "overlap": "false",
        "splines": "curved"
    }

    filename = file_path + 'architecture-with-che-server-engine'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 outformat="png",
                 edge_attr={"constraint": "false"},
                 ):
        controller = Custom(prod_short + ' server', prod_icon)
        kubernetes = APIServer(orch_name + ' API')
        workspace = Workspaces('User workspaces')
        controller >> kubernetes >> workspace

    filename = file_path + 'interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 #  edge_attr={"constraint": "false"},
                 ):
        che_server_components = Custom(
            prod_short + ' server components', prod_icon)
        devworkspace_engine = APIServer('DevWorkspace')
        workspace = Workspaces('User workspaces')
        che_server_components >> devworkspace_engine >> workspace

    filename = file_path + 'deployments-interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        user = User('User')
        role = Role('RBAC policies')
        che_gateway = Traefik('Gateway')
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = PostgreSQL('PostgreSQL')
        git = Git('Git provider')
        devfile_registries = SimpleStorageService('Devfile registries')
        plugin_registries = SimpleStorageService(
            'Plug-in registries')
        devworkspace_engine = APIServer('DevWorkspace engine')
        user_workspace = Workspaces('User workspaces')
        user >> role >> che_gateway >> [che_dashboard, user_workspace]
        che_dashboard >> [devfile_registries, che_host,
                          plugin_registries, devworkspace_engine]
        che_host >> [postgres, git]
        user_workspace >> devworkspace_engine

    filename = file_path + 'gateway-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        user = User('User')
        role = Role('RBAC policies')
        che_gateway = Traefik('Gateway')
        che_services = Custom(
            prod_short + ' services', icon_path=prod_icon)
        user_workspace = Workspaces('User workspaces')
        user >> role >> che_gateway >> [che_services, user_workspace]

    filename = file_path + 'user-dashboard-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        git = Git('Git repositories')
        devfile_registry = SimpleStorageService('Devfile registries')
        plugin_registry = SimpleStorageService('Plug-in registries')
        crd_workspace = APIServer('DevWorkspace engine')
        che_dashboard >> che_host,
        che_dashboard >> [
            devfile_registry, git, plugin_registry]
        che_dashboard >> crd_workspace

    filename = file_path + 'server-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
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

    filename = file_path + 'postgresql-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = PostgreSQL('PostgreSQL')
        che_host >> Edge(
            label='persists user configurations') >> postgres

    filename = file_path + 'devfile-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        devfile_registry = SimpleStorageService('Devfile registries')
        che_dashboard >> devfile_registry

    filename = file_path + 'plugin-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        plugin_registry = SimpleStorageService('Plug-in registries')
        che_dashboard >> plugin_registry

    filename = file_path + 'user-workspaces-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 #  edge_attr={"constraint": "false"},
                 graph_attr=graph_attr):
        devworkspace_engine = APIServer('DevWorkspace engine')
        workspace = Workspaces('User workspaces')
        devworkspace_engine << Edge(
        ) >> workspace


ArchitectureDiagrams(project_context='che',
                     prod_short='Che',
                     orch_name='Kubernetes')

ArchitectureDiagrams(project_context='crw',
                     prod_short='CodeReady Workspaces',
                     orch_name='OpenShift')
