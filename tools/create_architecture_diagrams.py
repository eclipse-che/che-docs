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
from diagrams.custom import Custom
from diagrams.k8s.controlplane import APIServer
from diagrams.k8s.network import SVC
from diagrams.k8s.others import CRD
from diagrams.k8s.rbac import User, Role
from diagrams.programming.flowchart import Database, MultipleDocuments
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
        controller = Custom('Workspace controller', prod_icon)
        kubernetes = APIServer(orch_name + ' API')
        workspace = MultipleDocuments('User workspaces')
        controller >> kubernetes >> workspace

    filename = file_path + 'interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 outformat="png",
                 edge_attr={"constraint": "false"},
                 ):
        che_server_components = Custom('Server components', prod_icon)
        devworkspace_engine = CRD('DevWorkspace')
        workspace = MultipleDocuments('User workspaces')
        che_server_components >> devworkspace_engine >> workspace

    filename = file_path + 'deployments-interacting-with-devworkspace'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        user = User('User')
        role = Role('Role')
        che_gateway = SVC('Gateway')
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = Database('PostgreSQL')
        registries = MultipleDocuments(
            'Devfile and plug-in registries')
        devworkspace_engine = CRD('DevWorkspace engine')
        user_workspace = MultipleDocuments('User workspaces')
        user >> role >> che_gateway >> [
            user_workspace, che_dashboard]
        che_dashboard >> che_host >> postgres
        [che_dashboard, che_host,
            devworkspace_engine] >> registries
        che_dashboard >> devworkspace_engine >> user_workspace
        che_dashboard >> user_workspace

    filename = file_path + 'gateway-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        user = User('User')
        role = Role('Role')
        che_gateway = SVC('Gateway')
        che_services = Custom(
            prod_short + ' services', icon_path=prod_icon)
        cr_devworkspace = CRD('DevWorkspace engine')
        user_workspace = MultipleDocuments('User workspaces')
        user >> role >> che_gateway >> [che_services,
                                        cr_devworkspace, user_workspace]

    filename = file_path + 'user-dashboard-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr_neato):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        devfile_registry = MultipleDocuments('Devfile registries')
        plugin_registry = MultipleDocuments('Plug-in registries')
        crd_workspace = CRD('DevWorkspace Custom Resources')
        user_workspace = MultipleDocuments('User workspaces')
        che_dashboard >> che_host,
        che_dashboard >> [
            devfile_registry, plugin_registry]
        che_dashboard >> crd_workspace
        che_dashboard >> user_workspace

    filename = file_path + 'server-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr_neato):
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = Database('PostgreSQL')
        devfile_registry = MultipleDocuments('Devfile registries')
        plugin_registry = MultipleDocuments('Plug-in registries')
        crd_workspace = CRD('DevWorkspace engine')
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_dashboard >> che_host
        che_host >> [devfile_registry, plugin_registry]
        che_host >> crd_workspace
        che_host >> postgres

    filename = file_path + 'postgresql-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr):
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        postgres = Database('PostgreSQL')
        che_host >> Edge(
            label='persists user configurations') >> postgres

    filename = file_path + 'devfile-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr_neato):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        devworkspace_engine = CRD('DevWorkspace engine')
        devfile_registry = MultipleDocuments('Devfile registries')
        [che_dashboard, che_host,
            devworkspace_engine] >> devfile_registry

    filename = file_path + 'plugin-registry-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="LR",
                 outformat="png",
                 graph_attr=graph_attr_neato):
        che_dashboard = Custom('User dashboard', icon_path=prod_icon)
        che_host = Custom(prod_short + ' server', icon_path=prod_icon)
        devworkspace_engine = CRD('DevWorkspace engine')
        plugin_registry = MultipleDocuments('Plug-in registries')
        [che_dashboard, che_host,
            devworkspace_engine] >> plugin_registry

    filename = file_path + 'user-workspaces-interactions'
    with Diagram(filename=filename,
                 show=False,
                 direction="TB",
                 outformat="png",
                 edge_attr={"constraint": "false"},
                 graph_attr=graph_attr_neato):
        dashboard = Custom('User dashboard', prod_icon)
        devworkspace_engine = CRD('DevWorkspace engine')
        workspace = MultipleDocuments('User workspaces')
        dashboard << Edge(
        ) >> [devworkspace_engine, workspace]
        workspace << Edge(
        ) >> devworkspace_engine


ArchitectureDiagrams(project_context='che',
                     prod_short='Che',
                     orch_name='Kubernetes')

ArchitectureDiagrams(project_context='crw',
                     prod_short='CodeReady Workspaces',
                     orch_name='OpenShift')
