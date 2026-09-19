/*
 * SMHasher3
 * Copyright (C) 2026  Thomas Dybdahl Ahle
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 */
//-----------------------------------------------------------------------------
// Seed differential tests - take a fixed pair of messages (m, m') that
// differ by complementing one or two 64-bit words, draw many uniformly
// random seeds, and count how often hash(m) == hash(m'). A good hash
// collides with probability 2^-hashbits per seed; multiply-fold hashes can
// be forced far above that by a message-controlled difference.

template <typename hashtype>
bool SeedDifferentialTest( const HashInfo * info, bool extra, flags_t flags );
