/*
 *  graph.h - helpful graph structure and setup/teardown methods
 *
 *  Copyright (c) 2007-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package alpm_auto

import "core:sys/posix"

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


_Alpm_Graph_Vertex_State :: enum u32 {
	UNPROCESSED = 0,
	PROCESSING  = 1,
	PROCESSED   = 2,
}

_Alpm_Graph :: struct {
	data:     rawptr,
	parent:   ^_Alpm_Graph, /* where did we come from? */
	children: ^List,
	iterator: ^List,        /* used for DFS without recursion */
	weight:   posix.off_t,  /* weight of the node */
	state:    _Alpm_Graph_Vertex_State,
}

Graph :: _Alpm_Graph

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	_alpm_graph_new  :: proc() -> ^Graph ---
	_alpm_graph_free :: proc(data: rawptr) ---
}

