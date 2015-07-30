//
//  UIView+AutoLayout.h
//
//  Created by Richard Turton on 18/10/2012.

#import <UIKit/UIKit.h>

/**
 *  Options for pinning item edges.
 */
typedef NS_OPTIONS(NSUInteger, JRTViewPinEdges)
{
    /// Pins the top edge of an item.
    JRTViewPinTopEdge = 1 << 0,
   
    /// Pins the right edge of an item.
    JRTViewPinRightEdge = 1 << 1,

    /// Pins the bottom edge of an item.
    JRTViewPinBottomEdge = 1 << 2,
    
    /// Pins the left edge of an item.
    JRTViewPinLeftEdge = 1 << 3,
    
    /// Pins all edges of an item.
    JRTViewPinAllEdges = ~0UL
};

/** This AutoLayout category provides convenience methods to make writing AutoLayout code less verbose than directly using the `NSLayoutConstraint` methods.
 
 For more information about these methods check out this blog post: http://commandshift.co.uk/blog/2013/02/20/creating-individual-layout-constraints/
 */

@interface UIView (AutoLayout)

/**
 * @name Initializing a View Object
 */

/**
 *  Returns a frameless view that does not automatically use autoresizing (for use in autolayouts).
 *
 *  @return A frameless view that does not automatically use autoresizing (for use in autolayouts).
 */
+(instancetype)autoLayoutView;


/** 
 * @name Pinning to the Superview 
 */

/**
 *  Pins a view to a specific edge(s) of its superview, with a specified inset.
 *
 *  @param edges The edges of the superview the receiver should pin to.
 *  @param inset The amount of space that the receiver should inset itself to within the superview.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)pinToSuperviewEdges:(JRTViewPinEdges)edges inset:(CGFloat)inset;

/**
 *  Pins a view to specific edge(s) of its superview, with a specified inset, using the layout guides of the viewController parameter for top and bottom pinning if appropriate.
 *
 *  @param edges The edges of the superview the receiver should pin to.
 *  @param inset The amount of space that the receiver should inset itself to within the superview.
 *  @param viewController The `UIViewController` with the top and bottom layout guides that should be respected by the method. Setting this value to `nil` will force the constraints to ignore the top and bottom layout guides. If the layout guides do not exist (pre iOS 7) then this method will ignore the layout guides.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)pinToSuperviewEdges:(JRTViewPinEdges)edges inset:(CGFloat)inset usingLayoutGuidesFrom:(UIViewController*)viewController;

/**
 *  Pins a view to all edges of its superview, with specified edge insets
 *
 *  @param insets The amount of space that the receiver should inset itself to within the superview from each edge.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)pinToSuperviewEdgesWithInset:(UIEdgeInsets)insets;


/** 
 * @name Centering Views 
 */

/**
 *  Centers the receiver in the specified view.
 *
 *  @param view The view you want to center the receiver in.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)centerInView:(UIView*)view;

/**
 *  Centers the receiver in the specified view on a specific axis.
 *
 *  @param view The view you want to center the receiver in.
 *  @param axis The axis of the superview you wish to center the receiver in. This parameter accepts `NSLayoutAttributeCenterX` or `NSLayoutAttributeCenterY`.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)centerInView:(UIView *)view onAxis:(NSLayoutAttribute)axis;

/**
 *  Centers the receiver in its superview on both the x and y axis.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)centerInContainer;

/**
 *  Centers the receiver in the superview on a specified axis.
 *
 *  @param axis The axis of the superview you wish to center the receiver in. This parameter accepts `NSLayoutAttributeCenterX` or `NSLayoutAttributeCenterY`.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)centerInContainerOnAxis:(NSLayoutAttribute)axis;


/**
 * @name Constraining to a fixed size
 */

/**
 *  Constrains the receiver to a fixed size.
 *  @warning Setting an axis to 0.0 will result in no constraint being applied to that axis.
 *
 *  @param size The size to constrain the receiver to.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)constrainToSize:(CGSize)size;

/**
 *  Constrains the receiver to a fixed width.
 *
 *  @param width The width to constrain the receiver to
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)constrainToWidth:(CGFloat)width;

/**
 *  Constrains the receiver to a fixed height.
 *
 *  @param height The height to constrain the receiver to
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)constrainToHeight:(CGFloat)height;

/**
 *  Applies the minimum and maximum size constrains to the receiver.
 *  @warning Setting an axis to 0.0 will result in no constraint being applied to that axis.
 *
 *  @param minimum The minimum size the receiver should be constrained to
 *  @param maximum The maximum size the receiver should be constrained to
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)constrainToMinimumSize:(CGSize)minimum maximumSize:(CGSize)maximum;

/**
 *  Applies the minimum size constrains to the receiver.
 *  @warning Setting an axis to 0.0 will result in no constraint being applied to that axis.
 *
 *  @param minimum The minimum size the receiver should be constrained to
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)constrainToMinimumSize:(CGSize)minimum;

/**
 *  Applies the maximum size constrains to the receiver.
 *  @warning Setting an axis to 0.0 will result in no constraint being applied to that axis.
 *
 *  @param maximum The maximum size the receiver should be constrained to
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)constrainToMaximumSize:(CGSize)maximum;


/**
 * @name Pinning to other items
 */

/**
 *  Pins an attribute to any valid attribute of the peer item. The item may be the layout guide of a view controller.
 *
 *  @param attribute     The attribute of the receiver that you want to pin.
 *  @param toAttribute   The attribute of the `peerView` that you want to pin.
 *  @param peerItem      The item that you want to pin the receiver to. (either `UIView` or `UILayoutSupport`).
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem;

/**
 *  Pins an attribute to any valid attribute of the peer item. The item may be the layout guide of a view controller. Provide a constant for offset/inset.
 *
 *  @param attribute     The attribute of the receiver that you want to pin.
 *  @param toAttribute   The attribute of the `peerView` that you want to pin.
 *  @param peerItem      The item that you want to pin the receiver to. (either `UIView` or `UILayoutSupport`).
 *  @param constant      The constant that you want to apply to the constraint.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem withConstant:(CGFloat)constant;

/**
 *  Pins an attribute to any valid attribute of the peer item. The item may be the layout guide of a view controller. Provide a constant for offset/inset along with a relation.
 *
 *  @param attribute     The attribute of the receiver that you want to pin.
 *  @param toAttribute   The attribute of the `peerView` that you want to pin.
 *  @param peerItem      The item that you want to pin the receiver to. (either `UIView` or `UILayoutSupport`).
 *  @param constant      The constant that you want to apply to the constraint.
 *  @param relation      The relation that you wish to apply to the constraint.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem withConstant:(CGFloat)constant relation:(NSLayoutRelation)relation;

/**
 *  Pins an attribute to the same attribute of the peer item. The item may be the layout guide of a view controller.
 *
 *  @param attribute The attribute of the receiver that you want to pin to the `peerView`.
 *  @param peerItem  The view you want to pin the receiver to.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfItem:(id)peerItem;

/**
 *  Pins an attribute to the same attribute of the peer item. The item may be the layout guide of a view controller. Provide a constant for offset/inset
 *
 *  @param attribute The attribute of the receiver that you want to pin to the `peerView`.
 *  @param peerItem  The view you want to pin the receiver to.
 *  @param constant  The constant to be applied to the constraint.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfItem:(id)peerItem withConstant:(CGFloat)constant;

/**
 *  Pins the receivers edge(s) to another views edge(s). Both views must be in the same view hierarchy.
 *
 *  @param edges    The edges that should be pinned to the peerView's edges.
 *  @param peerView The view that the receiver is being pinned to.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)pinEdges:(JRTViewPinEdges)edges toSameEdgesOfView:(UIView *)peerView;

/**
 *  Pins the receivers edge(s) to another views edge(s). Both views must be in the same view hierarchy.
 *
 *  @param edges    The edges that should be pinned to the peerView's edges.
 *  @param peerView The view that the receiver is being pinned to.
 *  @param inset    The inset that is applied to the attributes.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray *)pinEdges:(JRTViewPinEdges)edges toSameEdgesOfView:(UIView *)peerView inset:(CGFloat)inset;


/**
 * @name Pinning to a fixed point
 */

/**
 Pins a point to a specific point in the superview's frame. Use NSLayoutAttributeNotAnAttribute to only pin in one dimension.
 
 Acceptable values for x attribute:
 
 - `NSLayoutAttributeLeft`
 - `NSLayoutAttributeCenterX`
 - `NSLayoutAttributeRight`
 - `NSLayoutAttributeNotAnAttribute`

 Acceptable values for y attribute:
 
 - `NSLayoutAttributeTop`
 - `NSLayoutAttributeCenterY`
 - `NSLayoutAttributeBaseline`
 - `NSLayoutAttributeBottom`
 - `NSLayoutAttributeNotAnAttribute`
 
 @param x     The x attribute of the receiver that should be pinned.
 @param y     The y attribute of the receiver that should be pinned.
 @param point The point in the superview's frame that the receiver should be pinned to.
 
 @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)pinPointAtX:(NSLayoutAttribute)x Y:(NSLayoutAttribute)y toPoint:(CGPoint)point;


/**
 * @name Spacing Views
 */

/**
 *  Spaces the views evenly along the selected axis. 
 *  @warning Will force the views to the same size along the specified `axis` to fit.
 *
 *  @param views   The receivers subviews that should be spaced inside the receiver.
 *  @param axis    The axis that the subviews should be spaced along.
 *  @param spacing The spacing between the subviews being spaced.
 *  @param options The alignment options applied to the constraints.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)spaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options;


/**
 *  Spaces the views evenly along the selected axis, with optional flexibility allowed for the first view, in cases where the views do not divide evenly within the container.
 *
 *  @param views   The receivers subviews that should be spaced inside the receiver.
 *  @param axis    The axis that the subviews should be spaced along.
 *  @param spacing The spacing between the subviews being spaced.
 *  @param options The alignment options applied to the constraints.
 *  @param flexibleFirstItem Option to create constraints on the first view such that there is some flexibility on the width
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)spaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options flexibleFirstItem:(BOOL)flexibleFirstItem;

/**
 *  Spaces the views evenly along the selected axis, with optional flexibility allowed for the first view, in cases where the views do not divide evenly within the container.
 *
 *  @param views   The receivers subviews that should be spaced inside the receiver.
 *  @param axis    The axis that the subviews should be spaced along.
 *  @param spacing The spacing between the subviews being spaced.
 *  @param options The alignment options applied to the constraints.
 *  @param flexibleFirstItem Option to create constraints on the first view such that there is some flexibility on the width
 *  @param spaceEdges Determines if the spacing should be applied to the edges of each item or not. Defaults to `NO` in simplified methods.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)spaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options flexibleFirstItem:(BOOL)flexibleFirstItem applySpacingToEdges:(BOOL)spaceEdges;

/**
 *  Spaces the views evenly along the selected axis, using their intrinsic size
 *
 *  @param views The receivers subviews that should be spaced inside the receiver.
 *  @param axis  The axis that the subviews should be spaced along.
 *
 *  @return An array of `NSLayoutConstraint` objects generated by this method.
 */
-(NSArray*)spaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis;

@end


/** Deprecated methods are listed here.
 
 All methods listed in this document have been deprecated. The below documentation will provide instructions on how to migrate to the newer more flexible methods.
 
 @warning Deprecated methods will be removed in version 1.0.0.
 */

@interface UIView (AutoLayoutDeprecated)

/** 
 * @name Pinning Attributes of Views 
 */

/**
 *  Pin an attribute to the same attribute on another view. Both views must be in the same view hierarchy.
 *  @deprecated use pinAttribute:toSameAttributeOfItem: instead
 *
 *  @param attribute The attribute of the receiver that you want to pin to the `peerView`.
 *  @param peerView  The view you want to pin the receiver to.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfView:(UIView *)peerView DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toSameAttributeOfItem: instead");


/** 
 * @name Pinning Edges of Views 
 */

/**
 *  Pins a view's edge to a peer view's edge. Both views must be in the same view hierarchy.
 *  @deprecated use pinAttribute:toAttribute:ofItem: instead
 *
 *  @param edge     The edge of the receiver that you want to pin.
 *  @param toEdge   The edge of the `peerView` that you want to pin
 *  @param peerView The view that you want to pin the receiver to.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView*)peerView DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toAttribute:ofItem: instead");

/**
 *  Pins a view's edge to a peer view's edge, with an inset. Both views must be in the same view hierarchy.
 *  @deprecated use pinAttribute:toAttribute:ofItem:withConstant: instead
 *
 *  @param edge     The edge of the receiver that you want to pin.
 *  @param toEdge   The edge of the `peerView` that you want to pin
 *  @param peerView The view that you want to pin the receiver to.
 *  @param inset    The inset that you want to apply to the constraint
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)peerView inset:(CGFloat)inset DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toAttribute:ofItem:withConstant: instead");

/**
 *  Pins a view's edge to a peer item's edge. The item may be the layout guide of a view controller
 *  @deprecated use pinAttribute:toAttribute:ofItem instead
 *
 *  @param edge     The edge of the receiver that you want to pin.
 *  @param toEdge   The edge of the `peerView` that you want to pin
 *  @param peerItem The view that you want to pin the receiver to.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toAttribute:ofItem instead");

/**
 *  Pins a view's edge to a peer item's edge, with an inset. The item may be the layout guide of a view controller
 *  @deprecated use pinAttribute:toAttribute:ofItem:withConstant: instead
 *
 *  @param edge     The edge of the receiver that you want to pin.
 *  @param toEdge   The edge of the `peerView` that you want to pin
 *  @param peerItem The view that you want to pin the receiver to.
 *  @param inset    The inset that you want to apply to the constraint
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem inset:(CGFloat)inset DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toAttribute:ofItem:withConstant: instead");

/**
 *  Pins a view's edge to a peer item's edge, with an inset and a specific relation. The item may be the layout guide of a view controller.
 *  @deprecated use pinAttribute:toAttribute:ofItem:withConstant:relation: instead
 *
 *  @param edge     The edge of the receiver that you want to pin.
 *  @param toEdge   The edge of the `peerView` that you want to pin
 *  @param peerItem The view that you want to pin the receiver to.
 *  @param inset    The inset that you want to apply to the constraint
 *  @param relation The relation that you wish to apply to the constraint
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
-(NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem inset:(CGFloat)inset relation:(NSLayoutRelation)relation DEPRECATED_MSG_ATTRIBUTE("use pinAttribute:toAttribute:ofItem:withConstant:relation: instead");

@end
