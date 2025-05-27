import { LightningElement, track } from 'lwc';

export default class DragDropComponent extends LightningElement {
    @track boxes = [
        { id: '1', name: 'Box 1' },
        { id: '2', name: 'Box 2' },
        { id: '3', name: 'Box 3' },
    ];

    @track droppedBoxes = [];

    handleDragStart(event) {
        event.dataTransfer.setData('text/plain', event.target.dataset.id);
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        event.preventDefault();
        const boxId = event.dataTransfer.getData('text/plain');
        const containerType = event.target.dataset.container;

        if (containerType === 'initial') {
            this.moveBox(boxId, this.droppedBoxes, this.boxes);
        } else if (containerType === 'dropped') {
            this.moveBox(boxId, this.boxes, this.droppedBoxes);
        }
    }

    moveBox(boxId, fromList, toList) {
        const boxIndex = fromList.findIndex(box => box.id === boxId);

        if (boxIndex > -1) {
            const [box] = fromList.splice(boxIndex, 1);
            toList.push(box);
        }

        // Update tracked properties to trigger reactivity
        this.boxes = [...this.boxes];
        this.droppedBoxes = [...this.droppedBoxes];
    }
}