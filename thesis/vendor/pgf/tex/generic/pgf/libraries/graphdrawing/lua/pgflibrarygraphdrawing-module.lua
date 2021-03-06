-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot-fuse/pgf/pgf/generic/pgf/libraries/graphdrawing/lua/pgflibrarygraphdrawing-module.lua,v 1.2 2011/04/20 17:50:27 matthiasschulz Exp $

-- This file is mostly a dummy for creating the pgf.graphdrawing
-- namespace and importing the pgf namespace into it.

pgf.module("pgf.graphdrawing")
pgf.import("pgf")

-- just create the module and import the pgf module, basic setup
