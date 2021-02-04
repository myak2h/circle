import Sortable from 'sortablejs';
export default {
    mounted() {
        let dragged; // this will change so we use `let`
        const hook = this;
        const selector = '#' + this.el.id;
        console.log('The selector is:', selector);
        new Sortable(this.el, {
            animation: 0,
            delay: 50,
            delayOnTouchOnly: true,
            group: 'shared',
            draggable: '.draggable',
            ghostClass: 'sortable-ghost'
          });
    }
};