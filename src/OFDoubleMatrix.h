/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include <stdarg.h>

#import "OFObject.h"

@class OFDoubleVector;

/**
 * \brief A class for storing and manipulating matrices of doubles.
 */
@interface OFDoubleMatrix: OFObject <OFCopying>
{
@public
	size_t rows, columns;
	double *data;
}

/**
 * \brief Creates a new matrix with the specified dimension.
 *
 * If the number of rows and columns is equal, the matrix is initialized to be
 * the identity.
 *
 * \param rows The number of rows for the matrix
 * \param columns The number of colums for the matrix
 * \return A new autoreleased OFDoubleMatrix
 */
+ matrixWithRows: (size_t)rows
	 columns: (size_t)columns;

/**
 * \brief Creates a new matrix with the specified dimension and data.
 *
 * \param rows The number of rows for the matrix
 * \param columns The number of colums for the matrix
 * \param data The first double of the data for the matrix. The data is in the
 *	       format rows-columns.
 * \return A new autoreleased OFDoubleMatrix
 */
+ matrixWithRows: (size_t)rows
	 columns: (size_t)columns
	    data: (double)data, ...;

/**
 * \brief Initializes the matrix with the specified dimension.
 *
 * If the number of rows and columns is equal, the matrix is initialized to be
 * the identity.
 *
 * \param rows The number of rows for the matrix
 * \param columns The number of colums for the matrix
 * \return An initialized OFDoubleMatrix
 */
- initWithRows: (size_t)rows
       columns: (size_t)columns;

/**
 * \brief Initializes the matrix with the specified dimension and data.
 *
 * \param rows The number of rows for the matrix
 * \param columns The number of colums for the matrix
 * \param data The first double of the data for the matrix. The data is in the
 *	       format rows-columns.
 * \return An initialized OFDoubleMatrix
 */
-   initWithRows: (size_t)rows
	 columns: (size_t)columns
	    data: (double)data, ...;

/**
 * \brief Initializes the matrix with the specified dimension and arguments.
 *
 * \param rows The number of rows for the matrix
 * \param columns The number of colums for the matrix
 * \param data The first double of the data for the matrix. The data is in the
 *	       format rows-columns.
 * \param arguments A va_list with data for the matrix
 * \return An initialized OFDoubleMatrix
 */
- initWithRows: (size_t)rows
       columns: (size_t)columns
	  data: (double)data
     arguments: (va_list)arguments;

/**
 * \brief Sets the value for the specified row and colmn.
 *
 * \param value The value
 * \param row The row for the value
 * \param column The column for the value
 */
- (void)setValue: (double)value
	  forRow: (size_t)row
	  column: (size_t)column;

/**
 * \brief Returns the value for the specified row and column.
 *
 * \param row The row for which the value should be returned
 * \param column The column for which the value should be returned
 * \return The value for the specified row and column
 */
- (double)valueForRow: (size_t)row
	      column: (size_t)column;

/**
 * \brief Returns the number of rows of the matrix.
 *
 * \return The number of rows of the matrix
 */
- (size_t)rows;

/**
 * \brief Returns the number of columns of the matrix.
 *
 * \return The number of columns of the matrix
 */
- (size_t)columns;

/**
 * \brief Returns an array of doubles with the contents of the matrix.
 *
 * The returned array is in the format columns-rows.
 * Modifying the returned array directly is allowed and will change the matrix.
 *
 * \brief An array of doubles with the contents of the vector
 */
- (double*)cArray;

/**
 * \brief Adds the specified matrix to the receiver.
 *
 * \param matrix The matrix to add
 */
- (void)addMatrix: (OFDoubleMatrix*)matrix;

/**
 * \brief Subtracts the specified matrix from the receiver.
 *
 * \param matrix The matrix to subtract
 */
- (void)subtractMatrix: (OFDoubleMatrix*)matrix;

/**
 * \brief Multiplies the receiver with the specified scalar.
 *
 * \param scalar The scalar to multiply with
 */
- (void)multiplyWithScalar: (double)scalar;

/**
 * \brief Divides the receiver by the specified scalar.
 *
 * \param scalar The scalar to divide by
 */
- (void)divideByScalar: (double)scalar;

/**
 * \brief Multiplies the receiver with the specified matrix on the left side and
 * 	  the receiver on the right.
 *
 * \param matrix The matrix to multiply the receiver with
 */
- (void)multiplyWithMatrix: (OFDoubleMatrix*)matrix;

/**
 * \brief Transposes the receiver.
 */
- (void)transpose;

/**
 * \brief Translates the nxn matrix of the receiver with an n-1 vector.
 *
 * \param vector The vector to translate with
 */
- (void)translateWithVector: (OFDoubleVector*)vector;

/**
 * \brief Rotates the 4x4 matrix of the receiver with a 3D vector and an angle.
 *
 * \param vector The vector to rotate with
 * \param angle The angle to rotate with
 */
- (void)rotateWithVector: (OFDoubleVector*)vector
		   angle: (double)angle;

/**
 * \brief Scales the nxn matrix of the receiver with an n-1 vector.
 *
 * \param scale The vector to scale with
 */
- (void)scaleWithVector: (OFDoubleVector*)vector;
@end
