/*
 *  alpm_list.h
 *
 *  Copyright (c) 2006-2024 Pacman Development Team <pacman-dev@lists.archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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

foreign import lib "system:alpm"
_ :: lib

import "core:c/libc"
import "core:sys/linux"


/** A doubly linked list */
_Alpm_List :: struct {
	/** data held by the list node */
	data: rawptr,

	/** pointer to the previous node */
	prev: ^_Alpm_List,

	/** pointer to the next node */
	next: ^_Alpm_List,
}

/** A doubly linked list */
List :: _Alpm_List

/** item deallocation callback.
* @param item the item to free
*/
List_Fn_Free :: proc "c" (item: rawptr)

/** item comparison callback */
List_Fn_Cmp :: proc "c" (rawptr, rawptr) -> i32

@(default_calling_convention="c", link_prefix="alpm_")
foreign lib {
	/** Free a list, but not the contained data.
	*
	* @param list the list to free
	*/
	list_free :: proc(list: ^List) ---

	/** Free the internal data of a list structure but not the list itself.
	*
	* @param list the list to free
	* @param fn a free function for the internal data
	*/
	list_free_inner :: proc(list: ^List, fn: List_Fn_Free) ---

	/** Add a new item to the end of the list.
	*
	* @param list the list to add to
	* @param data the new item to be added to the list
	*
	* @return the resultant list
	*/
	list_add :: proc(list: ^List, data: rawptr) -> ^List ---

	/**
	* @brief Add a new item to the end of the list.
	*
	* @param list the list to add to
	* @param data the new item to be added to the list
	*
	* @return the newly added item
	*/
	list_append :: proc(list: ^^List, data: rawptr) -> ^List ---

	/**
	* @brief Duplicate and append a string to a list.
	*
	* @param list the list to append to
	* @param data the string to duplicate and append
	*
	* @return the newly added item
	*/
	list_append_strdup :: proc(list: ^^List, data: cstring) -> ^List ---

	/**
	* @brief Add items to a list in sorted order.
	*
	* @param list the list to add to
	* @param data the new item to be added to the list
	* @param fn   the comparison function to use to determine order
	*
	* @return the resultant list
	*/
	list_add_sorted :: proc(list: ^List, data: rawptr, fn: List_Fn_Cmp) -> ^List ---

	/**
	* @brief Join two lists.
	* The two lists must be independent. Do not free the original lists after
	* calling this function, as this is not a copy operation. The list pointers
	* passed in should be considered invalid after calling this function.
	*
	* @param first  the first list
	* @param second the second list
	*
	* @return the resultant joined list
	*/
	list_join :: proc(first: ^List, second: ^List) -> ^List ---

	/**
	* @brief Merge the two sorted sublists into one sorted list.
	*
	* @param left  the first list
	* @param right the second list
	* @param fn    comparison function for determining merge order
	*
	* @return the resultant list
	*/
	list_mmerge :: proc(left: ^List, right: ^List, fn: List_Fn_Cmp) -> ^List ---

	/**
	* @brief Sort a list of size `n` using mergesort algorithm.
	*
	* @param list the list to sort
	* @param n    the size of the list
	* @param fn   the comparison function for determining order
	*
	* @return the resultant list
	*/
	list_msort :: proc(list: ^List, n: i32, fn: List_Fn_Cmp) -> ^List ---

	/**
	* @brief Remove an item from the list.
	* item is not freed; this is the responsibility of the caller.
	*
	* @param haystack the list to remove the item from
	* @param item the item to remove from the list
	*
	* @return the resultant list
	*/
	list_remove_item :: proc(haystack: ^List, item: ^List) -> ^List ---

	/**
	* @brief Remove an item from the list.
	*
	* @param haystack the list to remove the item from
	* @param needle   the data member of the item we're removing
	* @param fn       the comparison function for searching
	* @param data     output parameter containing data of the removed item
	*
	* @return the resultant list
	*/
	list_remove :: proc(haystack: ^List, needle: rawptr, fn: List_Fn_Cmp, data: ^rawptr) -> ^List ---

	/**
	* @brief Remove a string from a list.
	*
	* @param haystack the list to remove the item from
	* @param needle   the data member of the item we're removing
	* @param data     output parameter containing data of the removed item
	*
	* @return the resultant list
	*/
	list_remove_str :: proc(haystack: ^List, needle: cstring, data: ^cstring) -> ^List ---

	/**
	* @brief Create a new list without any duplicates.
	*
	* This does NOT copy data members.
	*
	* @param list the list to copy
	*
	* @return a new list containing non-duplicate items
	*/
	list_remove_dupes :: proc(list: ^List) -> ^List ---

	/**
	* @brief Copy a string list, including data.
	*
	* @param list the list to copy
	*
	* @return a copy of the original list
	*/
	list_strdup :: proc(list: ^List) -> ^List ---

	/**
	* @brief Copy a list, without copying data.
	*
	* @param list the list to copy
	*
	* @return a copy of the original list
	*/
	list_copy :: proc(list: ^List) -> ^List ---

	/**
	* @brief Copy a list and copy the data.
	* Note that the data elements to be copied should not contain pointers
	* and should also be of constant size.
	*
	* @param list the list to copy
	* @param size the size of each data element
	*
	* @return a copy of the original list, data copied as well
	*/
	list_copy_data :: proc(list: ^List, size: i32) -> ^List ---

	/**
	* @brief Create a new list in reverse order.
	*
	* @param list the list to copy
	*
	* @return a new list in reverse order
	*/
	list_reverse :: proc(list: ^List) -> ^List ---

	/**
	* @brief Return nth element from list (starting from 0).
	*
	* @param list the list
	* @param n    the index of the item to find (n < alpm_list_count(list) IS needed)
	*
	* @return an alpm_list_t node for index `n`
	*/
	list_nth :: proc(list: ^List, n: i32) -> ^List ---

	/**
	* @brief Get the next element of a list.
	*
	* @param list the list node
	*
	* @return the next element, or NULL when no more elements exist
	*/
	list_next :: proc(list: ^List) -> ^List ---

	/**
	* @brief Get the previous element of a list.
	*
	* @param list the list head
	*
	* @return the previous element, or NULL when no previous element exist
	*/
	list_previous :: proc(list: ^List) -> ^List ---

	/**
	* @brief Get the last item in the list.
	*
	* @param list the list
	*
	* @return the last element in the list
	*/
	list_last :: proc(list: ^List) -> ^List ---

	/**
	* @brief Get the number of items in a list.
	*
	* @param list the list
	*
	* @return the number of list items
	*/
	list_count :: proc(list: ^List) -> i32 ---

	/**
	* @brief Find an item in a list.
	*
	* @param needle   the item to search
	* @param haystack the list
	* @param fn       the comparison function for searching (!= NULL)
	*
	* @return `needle` if found, NULL otherwise
	*/
	list_find :: proc(haystack: ^List, needle: rawptr, fn: List_Fn_Cmp) -> rawptr ---

	/**
	* @brief Find an item in a list.
	*
	* Search for the item whose data matches that of the `needle`.
	*
	* @param needle   the data to search for (== comparison)
	* @param haystack the list
	*
	* @return `needle` if found, NULL otherwise
	*/
	list_find_ptr :: proc(haystack: ^List, needle: rawptr) -> rawptr ---

	/**
	* @brief Find a string in a list.
	*
	* @param needle   the string to search for
	* @param haystack the list
	*
	* @return `needle` if found, NULL otherwise
	*/
	list_find_str :: proc(haystack: ^List, needle: cstring) -> cstring ---

	/**
	* @brief Check if two lists contain the same data, ignoring order.
	*
	* Lists are considered equal if they both contain the same data regardless
	* of order.
	*
	* @param left      the first list
	* @param right     the second list
	* @param fn        the comparison function
	*
	* @return 1 if the lists are equal, 0 if not equal, -1 on error.
	*/
	list_cmp_unsorted :: proc(left: ^List, right: ^List, fn: List_Fn_Cmp) -> i32 ---

	/**
	* @brief Find the differences between list `left` and list `right`
	*
	* The two lists must be sorted. Items only in list `left` are added to the
	* `onlyleft` list. Items only in list `right` are added to the `onlyright`
	* list.
	*
	* @param left      the first list
	* @param right     the second list
	* @param fn        the comparison function
	* @param onlyleft  pointer to the first result list
	* @param onlyright pointer to the second result list
	*
	*/
	list_diff_sorted :: proc(left: ^List, right: ^List, fn: List_Fn_Cmp, onlyleft: ^^List, onlyright: ^^List) ---

	/**
	* @brief Find the items in list `lhs` that are not present in list `rhs`.
	*
	* @param lhs the first list
	* @param rhs the second list
	* @param fn  the comparison function
	*
	* @return a list containing all items in `lhs` not present in `rhs`
	*/
	list_diff :: proc(lhs: ^List, rhs: ^List, fn: List_Fn_Cmp) -> ^List ---

	/**
	* @brief Copy a list and data into a standard C array of fixed length.
	* Note that the data elements are shallow copied so any contained pointers
	* will point to the original data.
	*
	* @param list the list to copy
	* @param n    the size of the list
	* @param size the size of each data element
	*
	* @return an array version of the original list, data copied as well
	*/
	list_to_array :: proc(list: ^List, n: i32, size: i32) -> rawptr ---
}

