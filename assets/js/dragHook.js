import Sortable from 'sortablejs';
export default {
    mounted() {
        const selector = '#' + this.el.id;
        let that = this
        new Sortable(this.el, {
            animation: 150,
            delay: 50,
            swapThreshold: 0.5,
            delayOnTouchOnly: true,
            group: 'shared',
            draggable: '.draggable',
            ghostClass: 'sortable-ghost',
            onUpdate: function () {
                const cards = Array.from(this.el.children).map(button => { return button.getAttribute("phx-value-card") });
                that.pushEvent("arrange", cards)
            }
        });
    }
};