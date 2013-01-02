/*
Feathers
Copyright (c) 2012 Josh Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls
{
	import feathers.core.IGroupedToggle;
	import feathers.core.ToggleGroup;

	import flash.errors.IllegalOperationError;

	import starling.events.Event;

	[Exclude(name="isToggle",kind="property")]

	/**
	 * A toggleable control that exists in a set that requires a single,
	 * exclusive toggled item.
	 *
	 * @see http://wiki.starling-framework.org/feathers/radio
	 * @see feathers.core.ToggleGroup
	 */
	public class Radio extends Button implements IGroupedToggle
	{
		/**
		 * If a <code>Radio</code> has not been added to a <code>ToggleGroup</code>,
		 * it will automatically be added to this group. If the Radio's
		 * <code>toggleGroup</code> property is set to a different group, it
		 * will be automatically removed from this group, if required.
		 */
		public static const defaultRadioGroup:ToggleGroup = new ToggleGroup();

		/**
		 * Constructor.
		 */
		public function Radio()
		{
			super.isToggle = true;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		/**
		 * @private
		 */
		override public function set isToggle(value:Boolean):void
		{
			throw IllegalOperationError("Radio isToggle must always be true.");
		}

		/**
		 * @private
		 */
		protected var _toggleGroup:ToggleGroup;

		/**
		 * @inheritDoc
		 */
		public function get toggleGroup():ToggleGroup
		{
			return this._toggleGroup;
		}

		/**
		 * @private
		 */
		public function set toggleGroup(value:ToggleGroup):void
		{
			if(this._toggleGroup == value)
			{
				return;
			}
			if(!value && this.stage)
			{
				value = defaultRadioGroup;
			}
			if(this._toggleGroup && this._toggleGroup.hasItem(this))
			{
				this._toggleGroup.removeItem(this);
			}
			this._toggleGroup = value;
			if(!this._toggleGroup.hasItem(this))
			{
				this._toggleGroup.addItem(this);
			}
		}

		/**
		 * @private
		 */
		protected function addedToStageHandler(event:Event):void
		{
			if(!this._toggleGroup)
			{
				this.toggleGroup = defaultRadioGroup;
			}
		}

		/**
		 * @private
		 */
		override protected function removedFromStageHandler(event:Event):void
		{
			if(this._toggleGroup == defaultRadioGroup)
			{
				this._toggleGroup.removeItem(this);
			}
			super.removedFromStageHandler(event);
		}
	}
}
